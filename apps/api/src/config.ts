/**
 * Config loader: all env parsing in one place.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const DEFAULT_DB_PATH = path.resolve(HERE, '../data/bladetide.db');
const LEGACY_DB_PATH = path.resolve(HERE, '../data/fishio.db');

/**
 * Resolve the SQLite file. `BLADETIDE_DB_PATH` wins; `FISHIO_DB_PATH` is kept
 * as a legacy alias. If neither is set and an old `fishio.db` exists, keep using
 * it so existing local accounts survive the rename.
 */
export function resolveDbPath(env: NodeJS.ProcessEnv = process.env): string {
  const explicit = env.BLADETIDE_DB_PATH || env.FISHIO_DB_PATH;
  if (explicit) return explicit;
  if (fs.existsSync(LEGACY_DB_PATH) && !fs.existsSync(DEFAULT_DB_PATH)) return LEGACY_DB_PATH;
  return DEFAULT_DB_PATH;
}

export interface ApiConfig {
  nodeEnv: 'development' | 'test' | 'production';
  host: string;
  port: number;
  databaseUrl: string;
  redisUrl: string;
  /** SQLite file backing local-dev accounts & save sync (Postgres is the production target). */
  dbPath: string;
  /** HMAC secret room servers use to sign match results (placeholder until M4). */
  internalHmacSecret: string;
  /** Browser origins allowed to call the API cross-site (e.g. the Vercel URL). Empty = same-origin only. */
  webOrigins: string[];
}

export function loadConfig(env: NodeJS.ProcessEnv = process.env): ApiConfig {
  const nodeEnv = (env.NODE_ENV as ApiConfig['nodeEnv']) ?? 'development';
  return {
    nodeEnv,
    host: env.HOST ?? '127.0.0.1',
    port: Number(env.PORT ?? 8080),
    databaseUrl: env.DATABASE_URL ?? '',
    redisUrl: env.REDIS_URL ?? '',
    dbPath: resolveDbPath(env),
    internalHmacSecret: env.INTERNAL_HMAC_SECRET ?? 'dev-secret-change-me',
    webOrigins: (env.WEB_ORIGIN ?? '')
      .split(',')
      .map((origin) => origin.trim().replace(/\/$/, ''))
      .filter(Boolean),
  };
}
