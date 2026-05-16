Config = {}

Config.MaxNameLength = 32
Config.StartingTreasury = 0
Config.RecruitRoleName = 'Recruit'
Config.LeaderRoleName = 'Leader'
Config.DailyReputationTickMinutes = 1440

Config.ReputationDefaults = {
    legitimacy = 0,
    force = 0,
    wealth = 0,
    intel = 0,
    culture = 0
}

Config.ReputationSources = {
    patrol = { legitimacy = 1, force = 1 },
    trade = { wealth = 2 },
    case = { intel = 2, legitimacy = 1 },
    event = { culture = 2 }
}

Config.Capabilities = {
    invite_member = true,
    promote_member = true,
    demote_member = true,
    deposit_funds = true,
    withdraw_funds = true,
    start_diplomacy = true,
    issue_bounty = true,
    declare_operation = true,
    set_tax_rate = true
}

Config.AdminGroups = {
    admin = true,
    superadmin = true
}

Config.AdminJobs = {
    sheriff = true,
    marshal = true
}
