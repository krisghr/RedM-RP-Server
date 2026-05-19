# nrrp-police

`nrrp-police` is a lightweight, text-only RedM police cell and jail management resource. It is designed for RP servers that already use another job system and do not want a full police framework.

This resource:

- Checks whether an officer has an allowed police job.
- Stores jail cell locked/unlocked state.
- Stores manual and online prisoner cell occupancy records.
- Supports timed jail sentences and indefinite RP holds.
- Provides `/cells` status output for officers.
- Persists cell state to `data/cells.json`.
- Logs police cell actions to the server console.

It does **not** create jobs, characters, inventories, courts, fines, warrants, or a framework dependency.

## Installation

1. Place the `nrrp-police` folder in your RedM resources directory.
2. Add this line to `server.cfg`:

   ```cfg
   ensure nrrp-police
   ```

3. Restart the server or run:

   ```text
   refresh
   ensure nrrp-police
   ```

## Configuration

All normal configuration is in `config.lua`.

### Debug logging

```lua
Config.Debug = false
```

Set this to `true` for extra client-side debug output while setting up doors.

### lo_jobscreator access

The resource checks `lo_jobscreator` server exports directly. It does **not** create or assign jobs.

To link a police job you created in `lo_jobscreator`:

1. Open your `lo_jobscreator` jobs panel/config and copy the technical job name, not just the display label.
2. Add that exact job name to `Config.AllowedJobs`.
3. Make sure officers are on duty for that job, because `nrrp-police` checks `exports.lo_jobscreator:IsDutyActive(source, jobName)`.

```lua
Config.UseLoJobsCreator = true
Config.AllowedJobs = {
    'valentine_sheriff',
    'blackwater_police',
    'saint_denis_police',
    'us_marshal'
}
```

For example, if your `lo_jobscreator` job is named `police`, use:

```lua
Config.AllowedJobs = {
    'police'
}
```

If your sheriff job is named `valentine_sheriff`, use:

```lua
Config.AllowedJobs = {
    'valentine_sheriff'
}
```

Optional fallback: if your jobs are categorized in `lo_jobscreator` with the `leo` job type and you want any online `leo` job to access cell commands, enable this in `config.lua`:

```lua
Config.AllowLoJobTypeFallback = true
Config.AllowedJobTypes = {
    'leo'
}
```

Keep `Config.AllowLoJobTypeFallback = false` if only the exact jobs listed in `Config.AllowedJobs` should have access.

### lo_jobscreator adapter details

`server.lua` includes `GetPlayerJobFromLoJobsCreator(source)`, which now uses the documented `lo_jobscreator` export:

```lua
exports.lo_jobscreator:IsDutyActive(source, jobName)
```

If your server later adds a custom export that returns a player's exact current job, you can still replace this adapter. With the documented exports provided, exact access is based on active duty state for each configured allowed job. Use `Config.AdminIdentifiers` for development/testing access if duty is not configured yet.

### Admin fallback access

For setup and testing, add full identifiers to:

```lua
Config.AdminIdentifiers = {
    -- 'license:xxxxxxxx',
    -- 'steam:110000xxxxxxxxx'
}
```

Anyone with a matching identifier can use police commands even if the job adapter is not finished yet.

### Stations and cells

`Config.Stations` stores station labels. `Config.Cells` stores each cell definition:

```lua
{
    id = 1,
    station = 'valentine',
    label = 'Valentine Cell 1',
    doorHash = nil,
    doorCoords = vector3(0.0, 0.0, 0.0),
    jailCoords = vector4(0.0, 0.0, 0.0, 0.0),
    releaseCoords = vector4(0.0, 0.0, 0.0, 0.0)
}
```

Replace the placeholder coordinates with your server's actual jail and release positions. The resource intentionally does not include real cell coordinates.

## Door locking notes

Door locked/unlocked state is persisted and broadcast to clients, but actual RedM door native code is intentionally isolated as a placeholder in `client.lua`:

```lua
RegisterNetEvent('nrrp-police:client:setDoorLocked', function(cellId, locked)
    -- TODO: Apply RedM door lock native here once door hashes are configured.
end)
```

After you identify your cell door hashes and preferred door-locking native/export, add that logic inside this event. The server-side `/cell lock` and `/cell unlock` commands already save and broadcast the state.

## Commands

All commands require `HasPoliceAccess(source)` to pass.

### `/cells`

Shows every configured cell and its current state:

- Cell label
- Locked/unlocked
- Empty/occupied
- Prisoner name
- Prisoner server ID if online
- Reason
- Status
- Detention type
- Release time for timed sentences
- Assigned by
- Notes

### `/cellassign [cellId] [name...]`

Creates a manual RP occupancy record without teleporting anyone.

Example:

```text
/cellassign 1 Glenn Conway
```

Useful for offline prisoners, narrative holds, or court RP records.

### `/cellclear [cellId]`

Clears the cell occupancy record without teleporting anyone.

Example:

```text
/cellclear 1
```

This preserves the current locked/unlocked door state.

### `/cellnote [cellId] [note...]`

Adds or updates a note on the cell record.

Example:

```text
/cellnote 1 Confessed to horse theft during interview
```

### `/cellstatus [cellId] [status...]`

Updates the status label on a cell record.

Examples:

```text
/cellstatus 1 Pending trial
/cellstatus 1 Awaiting sentencing
/cellstatus 1 Sentenced
/cellstatus 1 Transferred
```

### `/cell lock [cellId]`

Locks the configured cell door state and broadcasts the change.

Example:

```text
/cell lock 1
```

### `/cell unlock [cellId]`

Unlocks the configured cell door state and broadcasts the change.

Example:

```text
/cell unlock 1
```

### `/jailcell [cellId] [targetServerId] [time|indefinite|hold] [reason...]`

Teleports an online player into the configured cell, records their detention, locks the cell, saves state, notifies the officer/target, and logs the action.

Examples:

```text
/jailcell 1 34 30m Horse theft
/jailcell 1 34 2h Assault and robbery
/jailcell 1 34 indefinite Pending trial
/jailcell 1 34 hold Awaiting sentencing
```

Supported timed formats:

- `10m` = 10 minutes
- `2h` = 2 hours
- `1d` = 1 day

Supported indefinite formats:

- `indefinite`
- `hold`

Timed cells automatically release when the timer expires. Indefinite cells never auto-release.

### `/releasecell [cellId]`

Releases the prisoner from a cell. If the associated prisoner is online, they are teleported to `releaseCoords`. The occupancy record is cleared, the cell is unlocked, state is saved, and the action is logged.

Example:

```text
/releasecell 1
```

### `/sentencecell [cellId] [time|indefinite|release] [status/reason...]`

Updates a cell after trial or sentencing.

Examples:

```text
/sentencecell 1 45m Sentenced for disorderly conduct
/sentencecell 1 2h Sentenced for robbery
/sentencecell 1 indefinite Awaiting transport
/sentencecell 1 release Released by court order
```

If `release` is used, the command runs the same release logic as `/releasecell`.

## Timed vs indefinite detention

Timed detention uses a release timestamp:

```text
releaseAt = os.time() + duration
```

The server checks every 60 seconds for timed cells where `releaseAt <= os.time()`. If a timed sentence has expired, the resource releases the cell automatically.

Indefinite detention stores `releaseAt = nil` and will not auto-release. Use `/releasecell` or `/sentencecell [cellId] release ...` to release an indefinite hold.

## Persistence

Cell state is stored in:

```text
data/cells.json
```

On resource start, the resource:

1. Loads existing JSON if present.
2. Handles missing or malformed JSON safely.
3. Merges saved state with configured cells.
4. Ensures every configured cell has a state record.
5. Saves the merged state back to `data/cells.json`.

Do not manually edit `data/cells.json` while the resource is running unless you are prepared to restart/reload the resource afterward.

## Server logs

The resource prints useful logs for:

- Jail actions
- Manual assignments
- Releases
- Cell clears
- Door locks/unlocks
- Automatic releases
- Unauthorized command attempts

Logs are prefixed with:

```text
[nrrp-police]
```
