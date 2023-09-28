# Chinchilla CLI

A CLI for generating SQL-based database migration files and applying/rolling-back those migrations, powered by
[Chinchilla](https://github.com/slashmo/chinchilla).

## Installation

### Mint 🌱

You can install `chinchilla` via [`Mint`](https://github.com/yonaskolb/Mint):

`mint install slashmo/chinchilla-cli@0.1.0`

## Migration files

Chinchilla uses plain SQL files to define database migrations in both directions.
Each migration is split into two files, `*.up.sql` and `*.down.sql`.

For example, an "up" file may create a new table whereas its corresponding "down" file would delete that table.

| File | SQL |
| --- | --- |
| `20230928202100_create_users_table.up.sql` | `CREATE TABLE users (id UUID PRIMARY KEY)` |
| `20230928202100_create_users_table.down.sql` | `DROP TABLE users` |

> **Note**
> As you can see, migration files are prefixed with a date to make them unique and to preserve the order in which they
> are applied.

### Generate migration files

`chinchilla` ships with a handy command to generate migration files:

```sh
chinchilla generate create_users_table
```

This command creates two files, one for "up" and one for "down". By default, the files are written to a `migrations`
folder in the current working directory. Pass the `-f` flag if you wish to customize this location:

```sh
chinchilla generate -f path/to/migrations create_users_table
```
