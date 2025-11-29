-- Add migration script here
CREATE TABLE labels (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE ip_types (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE conn_states (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE connections (
    id BIGSERIAL PRIMARY KEY,
    resp_bytes BIGINT NOT NULL,
    orig_ip_bytes BIGINT NOT NULL,
    resp_pkts INT NOT NULL,
    history_length INT,
    proto_tcp BOOLEAN NOT NULL,
    label_id INT NOT NULL REFERENCES labels(id),
    ip_type_id INT NOT NULL REFERENCES ip_types(id)
);

CREATE TABLE connection_services (
    connection_id BIGINT REFERENCES connections(id) ON DELETE CASCADE,
    service_id INT REFERENCES services(id),
    PRIMARY KEY(connection_id, service_id)
);

CREATE TABLE connection_conn_states (
    connection_id BIGINT REFERENCES connections(id) ON DELETE CASCADE,
    conn_state_id INT REFERENCES conn_states(id),
    PRIMARY KEY(connection_id, conn_state_id)
);

-- Indexes
-- CREATE INDEX idx_connections_label ON connections(label_id);
-- CREATE INDEX idx_connections_ip_type ON connections(ip_type_id);
-- CREATE INDEX idx_connection_services_service ON connection_services(service_id);
-- CREATE INDEX idx_connection_conn_states_state ON connection_conn_states(conn_state_id);
