#pragma once

#include <QObject>
#include <QList>
#include <QTimer>
#include <QtQml/qqml.h>

// ─────────────────────────────────────────────
//  One entry from fleet.json
// ─────────────────────────────────────────────
struct FleetEntry {
    QString id;
    QString role;
    QString ip;
    int     port;
    QString protocol;   // "UDP" or "TCP"
    uint8_t sysid = 0;  // filled after first heartbeat
};

// ─────────────────────────────────────────────
//  FleetConfigLoader
//
//  Reads /home/asher/Stratum-gc/src/Fleet/fleet.json on startup.
//  For each entry creates a QGC UDP or TCP link.
//  Retries unreachable entries every RETRY_INTERVAL_MS.
// ─────────────────────────────────────────────
class FleetConfigLoader : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(FleetConfigLoader)
    QML_SINGLETON

public:
    static FleetConfigLoader* create(QQmlEngine*, QJSEngine*) {
        return instance();
    }
    static FleetConfigLoader* instance();

    // Call once at app startup
    void init();

    static constexpr const char* CONFIG_PATH = ":/Fleet/fleet.json";

private:
    explicit FleetConfigLoader(QObject* parent = nullptr);

    void loadConfig();
    void connectEntry(FleetEntry& entry);
    void retryOffline();

    QList<FleetEntry>   _entries;
    QTimer*             _retryTimer = nullptr;

    static constexpr int RETRY_INTERVAL_MS = 10000;   // 10s
};
