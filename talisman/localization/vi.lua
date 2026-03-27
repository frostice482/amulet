return {
    descriptions = {
        Mod = {
            Talisman = {
                name = "Talisman",
                text = { "Một mod tăng giới hạn điểm của Balatro và bỏ qua hoạt ảnh ghi điểm." },
            }
        }
    },
    test = "j",

    tal_disable_anims = 'Tắt Hoạt Ảnh Ghi Điểm',

    tal_disable_omega = 'Tắt OmegaNum (yêu cầu khởi động lại)',

    talisman_notation = 'Ký Hiệu số',
	talisman_notations_hypere = 'Hyper-E',
	talisman_notations_letter = 'Chữ Cái',
	talisman_notations_array = 'Mảng',

    tal_exp_colours = 'Màu cho ^Chip và ^Nhân',
    tal_exp_colour_default = 'Mặc Định',
    tal_exp_colour_classic = 'Cổ Điển (G.C.DARK_EDITION)',

    tal_debug_coroutine = 'Coroutine Gỡ Lỗi',
    tal_debug_coroutine_warning = {
        'Lưu lại stack trace của coroutine ghi điểm khi crash',
        'trong quá trình tính toán. Giúp hoạt động gỡ lỗi',
        'dễ dàng hơn khi crash'
    },

    tal_big_ante = 'Bật Big Ante',
    tal_big_ante_warning = {
        'Cho phép ante cao hơn 1e308.',
        'Lưu ý: không phải mod nào cũng hỗ trợ cái này.',
        ' ',
        '"nhưng mà sao lại bật thế"'
    },

    tal_enable_compat = 'Bật tương thích kiểu dữ liệu',
    tal_enable_compat_warning = {
        'Cảnh báo: Tương thích kiểu dữ liệu không hoạt động với',
        'một số mod, và có thể gây crash bất ngờ khi bật.'
    },

    tal_thread_sanitation = 'Sửa Lỗi Luồng',
    tal_thread_sanitation_warning = {
        'Hoạt động sửa lỗi của Amulet dành cho việc OmegaNum nhiễm vào luồng.',
        'copy: nhanh, đảm bảo tương thích, nhưng dùng nhiều bộ nhớ hơn',
        'modify: nhanh hơn, nhưng có thể gây crash/lỗi file',
        'noop: nhanh nhất, không làm gì, nhưng có thể gây crash',
    },

    tal_thread_sanitize_num = 'Sửa Lỗi Luồng: Chuyển thành số',

    tal_sanitize_graphics = 'Sửa Lỗi Đồ Hoạ',

    tal_calculating = 'Đang tính toán...',
    tal_abort = 'Huỷ bỏ',
    tal_elapsed = 'Phép tính đã thực hiện',
    tal_current_state = 'Hiện đang ghi điểm',
    tal_card_prog = 'Tiến trình lá bài ghi điểm',
    tal_luamem = 'Bộ nhớ Lua',
    tal_last_elapsed = 'Phép tính tay bài trước đó',
    tal_unknown = 'Không rõ',

    --These don't work out of the box because they would be called too early, find a workaround later?
    talisman_error_A = 'Could not find proper Talisman folder. Please make sure the folder for Talisman is named exactly "Talisman" and not "Talisman-main" or anything else.',
    talisman_error_B = '[Talisman] Error unpacking string: ',
    talisman_error_C = '[Talisman] Error loading string: '
}
