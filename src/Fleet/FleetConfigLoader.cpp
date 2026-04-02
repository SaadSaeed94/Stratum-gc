#include "FleetConfigLoader.h"
#include "FleetRegistry.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

#include "QGCApplication.h"
#include "LinkManager.h"
#include "TCPLink.h"
#include "UDPLink.h"

FleetConfigLoader* FleetConfigLoader::instance()
{
    static FleetConfigLoader* _instance = nullptr;
    if (!_instance) {
        _instance = new FleetConfigLoader(qgcApp());
    }
    return _instance;
}

FleetConfigLoader::FleetConfigLoader(QObject* parent)
    : QObject(parent)
{
    _retryTimer = new QTimer(this);
    _retryTimer->setInterval(RETRY_INTERVAL_MS);
    connect(_retryTimer, &QTimer::timeout, this, &FleetConfigLoader::retryOffline);
}

void FleetConfigLoader::init()
{
    loadConfig();
    if (!_entries.isEmpty()) {
        _retryTimer->start();
    }
}

void FleetConfigLoader::loadConfig()
{
    QFile file(CONFIG_PATH);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[FleetConfigLoader] Cannot open" << CONFIG_PATH
                   << "—" << file.errorString();
        return;
    }

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &err);
    if (err.error != QJsonParseError::NoError) {
        qWarning() << "[FleetConfigLoader] JSON parse error:" << err.errorString();
        return;
    }

    QJsonArray fleet = doc.object().value(QStringLiteral("fleet")).toArray();
    for (const QJsonValue& val : fleet) {
        QJsonObject obj = val.toObject();

        FleetEntry entry;
        entry.id       = obj.value(QStringLiteral("id")).toString();
        entry.role     = obj.value(QStringLiteral("role")).toString(QStringLiteral("ISR"));
        entry.ip       = obj.value(QStringLiteral("ip")).toString();
        entry.port     = obj.value(QStringLiteral("port")).toInt(14550);
        entry.protocol = obj.value(QStringLiteral("protocol")).toString(QStringLiteral("UDP")).toUpper();

        if (entry.ip.isEmpty()) {
            qWarning() << "[FleetConfigLoader] Skipping entry with no IP:" << entry.id;
            continue;
        }

        qDebug() << "[FleetConfigLoader] Loaded entry:"
                 << entry.id << entry.protocol << entry.ip << entry.port;

        _entries.append(entry);

                // Pre-enroll in registry so it shows in fleet panel immediately (as Offline)
        FleetRegistry::instance()->preEnroll(0, entry.id, entry.role);

                // Attempt connection
        connectEntry(_entries.last());
    }

    qDebug() << "[FleetConfigLoader] Loaded" << _entries.count() << "fleet entries";
}

void FleetConfigLoader::connectEntry(FleetEntry& entry)
{
    // LinkManager is now a singleton — no toolbox() needed
    LinkManager* linkMgr = LinkManager::instance();

    if (entry.protocol == QStringLiteral("UDP")) {
        UDPConfiguration* config = new UDPConfiguration(entry.id);
        config->addHost(entry.ip, static_cast<quint16>(entry.port));
        config->setDynamic(false);
        config->setAutoConnect(false);
        SharedLinkConfigurationPtr sharedConfig = linkMgr->addConfiguration(config);
        linkMgr->createConnectedLink(sharedConfig);
        qDebug() << "[FleetConfigLoader] UDP link created for" << entry.id
                 << entry.ip << ":" << entry.port;
    } else if (entry.protocol == QStringLiteral("TCP")) {
        TCPConfiguration* config = new TCPConfiguration(entry.id);
        config->setHost(entry.ip);                              // setAddress → setHost(QString)
        config->setPort(static_cast<quint16>(entry.port));
        config->setDynamic(false);
        config->setAutoConnect(false);
        SharedLinkConfigurationPtr sharedConfig = linkMgr->addConfiguration(config);
        linkMgr->createConnectedLink(sharedConfig);
        qDebug() << "[FleetConfigLoader] TCP link created for" << entry.id
                 << entry.ip << ":" << entry.port;
    } else {
        qWarning() << "[FleetConfigLoader] Unknown protocol:" << entry.protocol;
    }
}

void FleetConfigLoader::retryOffline()
{
    // LinkManager is now a singleton — no toolbox() needed
    LinkManager* linkMgr = LinkManager::instance();

    for (FleetEntry& entry : _entries) {
        bool isConnected = false;

                // links() returns QList<SharedLinkInterfacePtr> — iterate by const ref, not raw pointer
        const auto links = linkMgr->links();
        for (const SharedLinkInterfacePtr& link : links) {
            if (link->linkConfiguration()->name() == entry.id && link->isConnected()) {
                isConnected = true;
                break;
            }
        }

        if (!isConnected) {
            qDebug() << "[FleetConfigLoader] Retrying connection for" << entry.id;
            connectEntry(entry);
        }
    }
}
