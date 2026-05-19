return {
    descriptions = {
        Mod = {
            Talisman = {
                name = "Talisman",
                text = { "本mod旨在提高Balatro的得分和显示上限,并提供跳过得分动画的选项." },
            }
        }
    },
    test = "j",

    tal_disable_anims = '禁用得分动画',

    tal_disable_omega = '禁用超大数 (更改后重启生效)',

    talisman_notation = '数值显示格式',
    talisman_notations_hypere = 'Hyper-E记数法',
    talisman_notations_letter = '字母记数法',
    talisman_notations_array = '数组记数法',

    tal_exp_colours = '指数级增长的筹码和倍率颜色',
    tal_exp_colour_default = '默认',
    tal_exp_colour_classic = '经典深色 (G.C.DARK_EDITION)',

    tal_debug_coroutine = '协程调试',
    tal_debug_coroutine_warning = {
        '当分数计算过程中发生崩溃时',
        '截取该计算协程的报错讯息',
        '使除错变得稍微容易一些'
    },

    tal_big_ante = '启用大盲注',
    tal_big_ante_warning = {
        '允许盲注得分要求超过1e308.',
        '请注意,并非所有MOD都支持此功能',
        ' ',
        '"但为什么要这样做呢?"'
    },

    tal_enable_compat = '启用类型名称兼容模式',
    tal_enable_compat_warning = {
        '警告: 此兼容模式与部分MOD不兼容,',
        '启用时反而会导致预期之外的崩溃'
    },

    tal_thread_sanitation = '执行线程修复',
    tal_thread_sanitation_warning = {
        'Amulet针对超大数进入执行线程所做的修复方案',
        'copy: 快, 保证兼容性, 但可能占用更多内存',
        'modify: 更快, 但可能导致崩溃和存档损坏',
        'noop: 最快, 不执行任何操作, 但可能导致崩溃',
    },

    tal_thread_sanitize_num = '执行线程修复: 转换为数字',

    tal_sanitize_graphics = '图形修复',

    tal_calculating = '计算中...',
    tal_abort = '终止计算',
    tal_elapsed = '计算已耗时',
    tal_current_state = '正在计分',
    tal_card_prog = '已计分手牌进度',
    tal_luamem = 'Lua引擎占用内存',
    tal_last_elapsed = '上次手牌计算耗时',
    tal_unknown = '未知',

    --These don't work out of the box because they would be called too early, find a workaround later?
    talisman_error_A = '未找到正确的Talisman文件夹.请确保该文件夹命名准确为"Talisman",而不是"Talisman-main"或其他名字',
    talisman_error_B = '[Talisman] 字符串解包错误: ',
    talisman_error_C = '[Talisman] 字符串加载错误: '
}
