## faction_system

A first-pass faction system resource for NRRP.

## Features

- Faction creation (`/faction_create <name>`)
- Invite member (`/faction_invite <serverId>`)
- Faction treasury deposits/withdrawals (`/faction_deposit`, `/faction_withdraw`, `/faction_balance`)
- Capability-based permissions per role (stored as JSON)
- Daily reputation rollup from activity (`/faction_activity <type> [points]`)
- Automatic table bootstrap on resource start

## Add to server.cfg

```cfg
ensure faction_system
```

## Command quickstart

1. `/faction_create The Grizzlies`
2. `/faction_invite 12`
3. `/faction_deposit 100`
4. `/faction_activity patrol 3`
5. `/faction_balance`

## Activity types currently tracked

- `patrol`
- `trade`
- `case`
- `event`

Extend these in `shared/config.lua`.
