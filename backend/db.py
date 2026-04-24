from __future__ import annotations

import ssl
from urllib.parse import urlparse

import asyncpg


def _ssl_context_for_dsn(dsn: str) -> ssl.SSLContext | None:
    """Use TLS for Neon and other hosts that require encrypted Postgres."""

    lowered = dsn.lower()
    if "sslmode=disable" in lowered:
        return None
    if "sslmode=require" in lowered or "sslmode=verify-full" in lowered or "sslmode=verify-ca" in lowered:
        return ssl.create_default_context()
    try:
        host = (urlparse(dsn).hostname or "").lower()
    except Exception:
        host = ""
    if host.endswith(".neon.tech") or host.endswith(".neon.build"):
        return ssl.create_default_context()
    return None


USERS_SQL = """
CREATE TABLE IF NOT EXISTS users (
    uid TEXT PRIMARY KEY,
    role TEXT NOT NULL CHECK (role IN ('driver', 'operator')),
    email TEXT,
    display_name TEXT,
    fleet_id TEXT,
    device_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
"""

FLEETS_SQL = """
CREATE TABLE IF NOT EXISTS fleets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    owner_uid TEXT NOT NULL,
    invite_code TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fleets_owner_uid
ON fleets (owner_uid);

CREATE INDEX IF NOT EXISTS idx_fleets_invite_code
ON fleets (invite_code);

CREATE INDEX IF NOT EXISTS idx_users_fleet_role
ON users (fleet_id, role);

CREATE INDEX IF NOT EXISTS idx_users_device_id
ON users (device_id);
"""

DEVICE_STATUS_SQL = """
CREATE TABLE IF NOT EXISTS device_status (
    device_id TEXT PRIMARY KEY,
    online BOOLEAN NOT NULL,
    last_seen TIMESTAMPTZ NOT NULL,
    source TEXT NOT NULL,
    topic TEXT NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_device_status_last_seen
ON device_status (last_seen DESC);
"""

USERS_MIGRATION_SQL = """
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS display_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS fleet_id TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS device_id TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_device_id_key;
DROP INDEX IF EXISTS idx_users_device_id_unique;
"""

SCHEMA_SQL = """
CREATE TABLE IF NOT EXISTS alert_events (
    id BIGSERIAL PRIMARY KEY,
    device_id TEXT NOT NULL,
    level SMALLINT NOT NULL CHECK (level >= 0 AND level <= 2),
    message TEXT NOT NULL,
    source TEXT NOT NULL,
    topic TEXT NOT NULL,
    event_ts TIMESTAMPTZ NOT NULL,
    received_ts TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_alert_events_received_ts
ON alert_events (received_ts DESC);

CREATE INDEX IF NOT EXISTS idx_alert_events_device_received
ON alert_events (device_id, received_ts DESC);
"""


class Database:
    def __init__(
        self,
        dsn: str,
        min_size: int = 1,
        max_size: int = 10,
        command_timeout: float | None = None,
    ):
        self._dsn = dsn
        self._min_size = min_size
        self._max_size = max_size
        self._command_timeout = command_timeout
        self._pool: asyncpg.Pool | None = None

    @property
    def pool(self) -> asyncpg.Pool:
        if self._pool is None:
            raise RuntimeError("Database pool not initialized")
        return self._pool

    async def connect(self) -> None:
        ssl_ctx = _ssl_context_for_dsn(self._dsn)
        kwargs: dict = {
            "dsn": self._dsn,
            "min_size": self._min_size,
            "max_size": self._max_size,
            "max_inactive_connection_lifetime": 300.0,
        }
        if ssl_ctx is not None:
            kwargs["ssl"] = ssl_ctx
        if self._command_timeout is not None:
            kwargs["command_timeout"] = self._command_timeout
        self._pool = await asyncpg.create_pool(**kwargs)

    async def init_schema(self) -> None:
        async with self.pool.acquire() as conn:
            await conn.execute(SCHEMA_SQL)
            await conn.execute(USERS_SQL)
            await conn.execute(USERS_MIGRATION_SQL)
            await conn.execute(FLEETS_SQL)
            await conn.execute(DEVICE_STATUS_SQL)

    async def ping(self) -> None:
        async with self.pool.acquire() as conn:
            await conn.fetchval("SELECT 1")

    async def close(self) -> None:
        if self._pool is not None:
            await self._pool.close()
            self._pool = None
