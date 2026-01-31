return {
    descriptions = {
        Mod = {
            Talisman = {
                name = "Talisman",
                text = { "A mod that increases Balatro's score limit and skips scoring animations." },
            }
        }
    },
    test = "j",

    tal_disable_anims = 'Disable Scoring Animations',

    tal_disable_omega = 'Disable OmegaNum (requires restart)',

    talisman_notation = 'Number Notation',
    talisman_notations_hypere = 'Hyper-E',
    talisman_notations_letter = 'Letter',
    talisman_notations_array = 'Array',

    tal_debug_coroutine = 'Debug Coroutine',
    tal_debug_coroutine_warning = {
        'Captures stack trace of the scoring coroutine when',
        'crashed during calculation. Makes debugging slightly',
        'easier when crashed'
    },

    tal_big_ante = 'Enable Big Ante',
    tal_big_ante_warning = {
        'Allows ante over 1e308.',
        'Note that not all mods supports this.',
        '',
        '"but why tho"'
    },

    tal_enable_compat = 'Enable type compat',
    tal_enable_compat_warning = {
        'Warning: Type compat does not work with some mods,',
        'and instead will cause unexpected crash when enabled.'
    },

    tal_thread_sanitation = 'Thread Fix',
    tal_thread_sanitation_warning = {
        'Amulet\'s fix for OmegaNum getting into threads.',
        'copy: fast, guarantees compability, but can use more memory',
        'modify: faster, but can cause crash/corruption',
        'noop: fastest, does nothing, but can cause crash',
    },

    tal_thread_sanitize_num = 'Thread Fix: Convert to numbers',

    tal_calculating = 'Calculating...',
    tal_abort = 'Abort',
    tal_elapsed = 'Elapsed calculations',
    tal_current_state = 'Currently scoring',
    tal_card_prog = 'Scored card progress',
    tal_luamem = 'Lua memory',
    tal_last_elapsed = 'Calculations last played hand',
    tal_unknown = 'Unknown',

    --These don't work out of the box because they would be called too early, find a workaround later?
    talisman_error_A = 'Could not find proper Talisman folder. Please make sure the folder for Talisman is named exactly "Talisman" and not "Talisman-main" or anything else.',
    talisman_error_B = '[Talisman] Error unpacking string: ',
    talisman_error_C = '[Talisman] Error loading string: '
}
