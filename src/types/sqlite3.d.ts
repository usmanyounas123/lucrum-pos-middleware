import { Database } from 'sqlite3';

export interface DbRow {
  [key: string]: any;
}

export interface DatabaseResult {
  changes?: number;
  lastID?: number;
}

export type DatabaseCallback = (err: Error | null, result?: any) => void;

declare module 'sqlite3' {
  interface Database {
    run(sql: string, params: any[], callback: (this: DatabaseResult, err: Error | null) => void): void;
    run(sql: string, callback: (this: DatabaseResult, err: Error | null) => void): void;
    get(sql: string, params: any[], callback: (err: Error | null, row?: DbRow) => void): void;
    all(sql: string, params: any[], callback: (err: Error | null, rows: DbRow[]) => void): void;
  }
}