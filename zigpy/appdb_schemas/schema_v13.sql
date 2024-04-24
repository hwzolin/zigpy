PRAGMA user_version = 13;

-- devices
DROP TABLE IF EXISTS devices_v13;
CREATE TABLE devices_v13 (
    ieee ieee NOT NULL,
    nwk INTEGER NOT NULL,
    status INTEGER NOT NULL,
    last_seen REAL NOT NULL
);

CREATE UNIQUE INDEX devices_idx_v13
    ON devices_v13(ieee);


-- endpoints
DROP TABLE IF EXISTS endpoints_v13;
CREATE TABLE endpoints_v13 (
    ieee ieee NOT NULL,
    endpoint_id INTEGER NOT NULL,
    profile_id INTEGER NOT NULL,
    device_type INTEGER NOT NULL,
    status INTEGER NOT NULL,

    FOREIGN KEY(ieee)
        REFERENCES devices_v13(ieee)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX endpoint_idx_v13
    ON endpoints_v13(ieee, endpoint_id);


-- clusters
DROP TABLE IF EXISTS clusters_v13;
CREATE TABLE clusters_v13 (
    ieee ieee NOT NULL,
    endpoint_id INTEGER NOT NULL,
    cluster_type INTEGER NOT NULL,
    cluster_id INTEGER NOT NULL,

    FOREIGN KEY(ieee, endpoint_id)
        REFERENCES endpoints_v13(ieee, endpoint_id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX clusters_idx_v13
    ON clusters_v13(ieee, endpoint_id, cluster_type, cluster_id);


-- attributes
DROP TABLE IF EXISTS attributes_cache_v13;
CREATE TABLE attributes_cache_v13 (
    ieee ieee NOT NULL,
    endpoint_id INTEGER NOT NULL,
    cluster_type INTEGER NOT NULL,
    cluster_id INTEGER NOT NULL,
    attr_id INTEGER NOT NULL,
    value BLOB NOT NULL,
    last_updated REAL NOT NULL,

    -- Quirks can create "virtual" clusters and endpoints that won't be present in the
    -- DB but whose values still need to be cached
    FOREIGN KEY(ieee)
        REFERENCES devices_v13(ieee)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX attributes_cache_idx_v13
    ON attributes_cache_v13(ieee, endpoint_id, cluster_type, cluster_id, attr_id);


-- neighbors
DROP TABLE IF EXISTS neighbors_v13;
CREATE TABLE neighbors_v13 (
    device_ieee ieee NOT NULL,
    extended_pan_id ieee NOT NULL,
    ieee ieee NOT NULL,
    nwk INTEGER NOT NULL,
    device_type INTEGER NOT NULL,
    rx_on_when_idle INTEGER NOT NULL,
    relationship INTEGER NOT NULL,
    reserved1 INTEGER NOT NULL,
    permit_joining INTEGER NOT NULL,
    reserved2 INTEGER NOT NULL,
    depth INTEGER NOT NULL,
    lqi INTEGER NOT NULL,

    FOREIGN KEY(device_ieee)
        REFERENCES devices_v13(ieee)
        ON DELETE CASCADE
);

CREATE INDEX neighbors_idx_v13
    ON neighbors_v13(device_ieee);


-- routes
DROP TABLE IF EXISTS routes_v13;
CREATE TABLE routes_v13 (
    device_ieee ieee NOT NULL,
    dst_nwk INTEGER NOT NULL,
    route_status INTEGER NOT NULL,
    memory_constrained INTEGER NOT NULL,
    many_to_one INTEGER NOT NULL,
    route_record_required INTEGER NOT NULL,
    reserved INTEGER NOT NULL,
    next_hop INTEGER NOT NULL
);

CREATE INDEX routes_idx_v13
    ON routes_v13(device_ieee);


-- node descriptors
DROP TABLE IF EXISTS node_descriptors_v13;
CREATE TABLE node_descriptors_v13 (
    ieee ieee NOT NULL,

    logical_type INTEGER NOT NULL,
    complex_descriptor_available INTEGER NOT NULL,
    user_descriptor_available INTEGER NOT NULL,
    reserved INTEGER NOT NULL,
    aps_flags INTEGER NOT NULL,
    frequency_band INTEGER NOT NULL,
    mac_capability_flags INTEGER NOT NULL,
    manufacturer_code INTEGER NOT NULL,
    maximum_buffer_size INTEGER NOT NULL,
    maximum_incoming_transfer_size INTEGER NOT NULL,
    server_mask INTEGER NOT NULL,
    maximum_outgoing_transfer_size INTEGER NOT NULL,
    descriptor_capability_field INTEGER NOT NULL,

    FOREIGN KEY(ieee)
        REFERENCES devices_v13(ieee)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX node_descriptors_idx_v13
    ON node_descriptors_v13(ieee);


-- groups
DROP TABLE IF EXISTS groups_v13;
CREATE TABLE groups_v13 (
    group_id INTEGER NOT NULL,
    name TEXT NOT NULL
);

CREATE UNIQUE INDEX groups_idx_v13
    ON groups_v13(group_id);


-- group members
DROP TABLE IF EXISTS group_members_v13;
CREATE TABLE group_members_v13 (
    group_id INTEGER NOT NULL,
    ieee ieee NOT NULL,
    endpoint_id INTEGER NOT NULL,

    FOREIGN KEY(group_id)
        REFERENCES groups_v13(group_id)
        ON DELETE CASCADE,
    FOREIGN KEY(ieee, endpoint_id)
        REFERENCES endpoints_v13(ieee, endpoint_id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX group_members_idx_v13
    ON group_members_v13(group_id, ieee, endpoint_id);


-- relays
DROP TABLE IF EXISTS relays_v13;
CREATE TABLE relays_v13 (
    ieee ieee NOT NULL,
    relays BLOB NOT NULL,

    FOREIGN KEY(ieee)
        REFERENCES devices_v13(ieee)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX relays_idx_v13
    ON relays_v13(ieee);


-- unsupported attributes
DROP TABLE IF EXISTS unsupported_attributes_v13;
CREATE TABLE unsupported_attributes_v13 (
    ieee ieee NOT NULL,
    endpoint_id INTEGER NOT NULL,
    cluster_type INTEGER NOT NULL,
    cluster_id INTEGER NOT NULL,
    attr_id INTEGER NOT NULL,

    FOREIGN KEY(ieee)
        REFERENCES devices_v13(ieee)
        ON DELETE CASCADE,
    FOREIGN KEY(ieee, endpoint_id, cluster_type, cluster_id)
        REFERENCES clusters_v13(ieee, endpoint_id, cluster_type, cluster_id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX unsupported_attributes_idx_v13
    ON unsupported_attributes_v13(ieee, endpoint_id, cluster_type, cluster_id, attr_id);


-- network backups
DROP TABLE IF EXISTS network_backups_v13;
CREATE TABLE network_backups_v13 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    backup_json TEXT NOT NULL
);