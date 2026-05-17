---@diagnostic disable: undefined-global
-- ############################################################################
-- #                       EDITABLE FILE (TEMPLATES)                           #
-- #                                                                           #
-- #   Quick-install job templates exposed in the admin panel under the        #
-- #   "Templates" tab. Each entry creates one job (with grades) when the      #
-- #   admin clicks Install.                                                   #
-- #                                                                           #
-- #   Edit, add or remove entries freely. Field reference:                    #
-- #     name      = technical job name written into the DB. Other scripts     #
-- #                 check this value (e.g. char.job == 'sheriff'), so do not  #
-- #                 change it after players have started using a job.         #
-- #     labelKey  = i18n key resolved server-side at install time. Set the    #
-- #                 visible label by editing locales/fr.json + locales/en.json #
-- #                 (or whichever language file your server uses).            #
-- #     type      = job category used by the panel filters.                   #
-- #     grades[]  = grade list, payment is the per-pay-cycle amount.          #
-- #                                                                           #
-- #   To translate to a new language, copy the keys below into your locale    #
-- #   file. Missing keys fall back to the key string itself.                  #
-- ############################################################################

JobTemplates = {
    sheriff_basic = {
        name = 'sheriff',
        labelKey = 'tpl_sheriff_basic_label',
        type = 'leo',
        grades = {
            { id = 0, nameKey = 'tpl_sheriff_basic_grade_0', payment = 100, isboss = false },
            { id = 1, nameKey = 'tpl_sheriff_basic_grade_1', payment = 200, isboss = false },
            { id = 2, nameKey = 'tpl_sheriff_basic_grade_2', payment = 300, isboss = false },
            { id = 3, nameKey = 'tpl_sheriff_basic_grade_3', payment = 400, isboss = false },
            { id = 4, nameKey = 'tpl_sheriff_basic_grade_4', payment = 500, isboss = true  },
        },
    },
    medic_basic = {
        name = 'medecin',
        labelKey = 'tpl_medic_basic_label',
        type = 'medic',
        grades = {
            { id = 0, nameKey = 'tpl_medic_basic_grade_0', payment = 100, isboss = false },
            { id = 1, nameKey = 'tpl_medic_basic_grade_1', payment = 200, isboss = false },
            { id = 2, nameKey = 'tpl_medic_basic_grade_2', payment = 350, isboss = false },
            { id = 3, nameKey = 'tpl_medic_basic_grade_3', payment = 500, isboss = true  },
        },
    },
    saloon_basic = {
        name = 'saloon',
        labelKey = 'tpl_saloon_basic_label',
        type = 'service',
        grades = {
            { id = 0, nameKey = 'tpl_saloon_basic_grade_0', payment = 80,  isboss = false },
            { id = 1, nameKey = 'tpl_saloon_basic_grade_1', payment = 150, isboss = false },
            { id = 2, nameKey = 'tpl_saloon_basic_grade_2', payment = 300, isboss = true  },
        },
    },
    blacksmith = {
        name = 'forgeron',
        labelKey = 'tpl_blacksmith_label',
        type = 'service',
        grades = {
            { id = 0, nameKey = 'tpl_blacksmith_grade_0', payment = 80,  isboss = false },
            { id = 1, nameKey = 'tpl_blacksmith_grade_1', payment = 180, isboss = false },
            { id = 2, nameKey = 'tpl_blacksmith_grade_2', payment = 300, isboss = true  },
        },
    },
    farmer = {
        name = 'fermier',
        labelKey = 'tpl_farmer_label',
        type = 'production',
        grades = {
            { id = 0, nameKey = 'tpl_farmer_grade_0', payment = 80,  isboss = false },
            { id = 1, nameKey = 'tpl_farmer_grade_1', payment = 160, isboss = false },
            { id = 2, nameKey = 'tpl_farmer_grade_2', payment = 280, isboss = true  },
        },
    },
    cheminot = {
        name = 'cheminot',
        labelKey = 'tpl_cheminot_label',
        type = 'transport',
        grades = {
            { id = 0, nameKey = 'tpl_cheminot_grade_0', payment = 80,  isboss = false },
            { id = 1, nameKey = 'tpl_cheminot_grade_1', payment = 180, isboss = false },
            { id = 2, nameKey = 'tpl_cheminot_grade_2', payment = 300, isboss = true  },
        },
    },
    butcher = {
        name = 'boucher',
        labelKey = 'tpl_butcher_label',
        type = 'service',
        grades = {
            { id = 0, nameKey = 'tpl_butcher_grade_0', payment = 100, isboss = false },
            { id = 1, nameKey = 'tpl_butcher_grade_1', payment = 250, isboss = true  },
        },
    },
    banker = {
        name = 'banquier',
        labelKey = 'tpl_banker_label',
        type = 'service',
        grades = {
            { id = 0, nameKey = 'tpl_banker_grade_0', payment = 100, isboss = false },
            { id = 1, nameKey = 'tpl_banker_grade_1', payment = 200, isboss = false },
            { id = 2, nameKey = 'tpl_banker_grade_2', payment = 300, isboss = false },
            { id = 3, nameKey = 'tpl_banker_grade_3', payment = 500, isboss = true  },
        },
    },
}
