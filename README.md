# Chinchilla CLI

A CLI for generating SQL-based database migration files and applying/rolling-back those migrations, powered by
[Chinchilla](https://github.com/slashmo/chinchilla).

## Installation

### Mint 🌱

You can install `chinchilla` via [`Mint`](https://github.com/yonaskolb/Mint):

```sh
mint install slashmo/chinchilla-cli@main
```

### From source 🏭

You can also build `chinchilla` directly from source:

1. Clone this repository
2. Open the repository folder in your Terminal
3. Use `swift` to compile the project:

```sh
swift build -c release
```

4. Invoke `chinchilla`:

```sh
./.build/release/chinchilla --help
```

## Configuration

Chinchilla can be configured in a couple of ways.
> **Note**
> Feel free to mix different configuration methods, but be aware of the
> [order in which they apply](#configuration-value-specificity).

### Explicit command arguments

Most configuration options can be set directly via CLI arguments. Check out the `--help` text of the command you wish
to run to see the available arguments.

### Environment variables

Configuration options may also be passed via environment variables. This is the recommended way to pass sensitive
information such as your database password.

### YAML configuration file

Chinchilla supports file-based configuration in YAML. By default, all commands read `chinchilla.yml` within your
current directory. If this file doesn't exist, Chinchilla falls back to other configuration methods. You may also use
a YAML file at a different location by passing the `-c`/`--config` flag to `chinchilla`.

#### Example file

```yml
version: 1.0
migrations_path: /path/to/migrations
```

### Configuration Value Specificity

Configuration values are determined in the following order:

1. Use the CLI argument, if set
2. Use the environment variable, if set
3. Use the value specified in the config file, if set
4. Fall back to a sensible default if possible
5. If no fall-back exists, fail execution

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

This command creates two files, one for "up" and one for "down".
