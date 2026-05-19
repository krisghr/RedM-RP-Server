Config = {}

Config.Debug = true
Config.UseLoJobsCreator = true

-- Optional fallback: if true, players in these lo_jobscreator job types can use
-- police commands even when their exact job name is not listed in Config.AllowedJobs.
-- Keep this false if you only want the exact Config.AllowedJobs jobs to have access.
Config.AllowLoJobTypeFallback = false
Config.AllowedJobTypes = {
    'leo'
}

Config.AllowedJobs = {
    'valentine_sheriff',
    'blackwater_sheriff',
    'saint_denis_police',
    'us_marshal'
}

-- Add full identifiers here for development/testing access bypasses.
-- Examples: 'license:xxxxxxxx', 'steam:110000xxxxxxxxx', 'fivem:123456'
Config.AdminIdentifiers = {}


Config.DefaultIndefiniteLabels = {
    indefinite = 'Pending trial',
    hold = 'Awaiting sentencing',
    manual = 'Manual record'
}

Config.Stations = {
    valentine = {
        label = 'Valentine Sheriff Office'
    },
    blackwater = {
        label = 'Blackwater Police Department'
    },
    saint_denis = {
        label = 'Saint Denis Police Department'
    }
}

-- Replace these placeholder coordinates with your server's actual cells.
Config.Cells = {
    {
        id = 1,
        station = 'blackwater',
        label = 'Blackwater Jail',
        jailCoords = vector4(-766.9160, -1232.6421, 35.5071, 181.1303),
        releaseCoords = vector4(-762.1951, -1229.3816, 35.5071, 270.5755)
    },
    {
        id = 2,
        station = 'valentine',
        label = 'Valentine Cell 2',
        jailCoords = vector4(0.0, 0.0, 0.0, 0.0),
        releaseCoords = vector4(0.0, 0.0, 0.0, 0.0)
    }
}
