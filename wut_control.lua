#!/usr/bin/env lua

--[[
-- Copyright (c) 2023 Florian Kutzer <info@florian-kutzer.de>
-- 
-- Permission to use, copy, modify, and distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]--

wut_protocol = Proto("WuT-Control", "W_T Comserver Protocol")

zero_1 = ProtoField.char("wut.zero_1", "zero_1")
zero_2 = ProtoField.char("wut.zero_2", "zero_2")

-- baud type
local baud_types = {
[0] = 57600,
[1] = 38400,
[2] = 19200,
[3] = 9600,
[5] = 4800,
[6] = 2400,
[7] = 1200,
[8] = 600,
[9] = 300,
[10] = 150,
[11] = 230400,
[12] = 75,
[13] = 50,
[14] = 153600,
[15] = 115200,
[16] = 110
}

-- bit type
local databit_types = {
[2] = 7,
[3] = 8
}

local stopbit_types = {
[0] = 1,
[1] = 2
}

local parity_types = {
[0] = "odd",
[1] = "even"
}

-- com_error
com_error_f_data = ProtoField.uint16("wut.com_error.f_data", "f_data", nil, nil, 0x1)
com_error_f_net = ProtoField.uint16("wut.com_error.f_net", "f_net", nil, nil, 0x6)
com_error_f_com = ProtoField.uint16("wut.com_error.f_com", "f_com", nil, nil, 0x8)
com_error_f_break = ProtoField.uint16("wut.com_error.f_break", "f_break", nil, nil, 0x10)
com_error_f_cts_time = ProtoField.uint16("wut.com_error.f_cts_time", "f_cts_time", nil, nil, 0x20)
com_error_f_dsr_time = ProtoField.uint16("wut.com_error.f_dsr_time", "f_dsr_time", nil, nil, 0x40)
com_error_f_rlsd_time = ProtoField.uint16("wut.com_error.f_rlsd_time", "f_rlsd_time", nil, nil, 0x80)
com_error_f_overrun = ProtoField.uint16("wut.com_error.f_overrun", "f_overrun", nil, nil, 0x100)
com_error_f_parity = ProtoField.uint16("wut.com_error.f_parity", "f_parity", nil, nil, 0x200)
com_error_f_frame = ProtoField.uint16("wut.com_error.f_frame", "f_frame", nil, nil, 0x400)
com_error_f_status = ProtoField.uint16("wut.com_error.f_status", "f_status", nil, nil, 0x800)
com_error_no_use_1 = ProtoField.uint16("wut.com_error.no_use_1", "no_use_1", nil, nil, 0x1000)
com_error_no_use_2 = ProtoField.uint16("wut.com_error.no_use_2", "no_use_2", nil, nil, 0x2000)
com_error_f_rx_over = ProtoField.uint16("wut.com_error.f_rx_over", "f_rx_over", nil, nil, 0x4000)
com_error_no_use_3 = ProtoField.uint16("wut.com_error.no_use_3", "no_use_3", nil, nil, 0x8000)

-- com_stat
com_stat_cts_hold = ProtoField.uint16("wut.com_stat.cts_hold", "cts_hold", nil, nil, 0x1)
com_stat_dsr_hold = ProtoField.uint16("wut.com_stat.dsr_hold", "dsr_hold", nil, nil, 0x2)
com_stat_ri_hold = ProtoField.uint16("wut.com_stat.ri_hold", "ri_hold", nil, nil, 0x4)
com_stat_rlsd_hold = ProtoField.uint16("wut.com_stat.rlsd_hold", "rlsd_hold", nil, nil, 0x8)
com_stat_dtr_hold = ProtoField.uint16("wut.com_stat.dtr_hold", "dtr_hold", nil, nil, 0x10)
com_stat_rts_hold = ProtoField.uint16("wut.com_stat.rts_hold", "rts_hold", nil, nil, 0x20)
com_stat_x_receive = ProtoField.uint16("wut.com_stat.x_receive", "x_receive", nil, nil, 0x40)
com_stat_x_send = ProtoField.uint16("wut.com_stat.x_send", "x_send", nil, nil, 0x80)
com_stat_break_mode = ProtoField.uint16("wut.com_stat.break_mode", "break_mode", nil, nil, 0x100)
com_stat_dummy = ProtoField.uint16("wut.com_stat.dummy", "dummy", nil, nil, 0x200)
com_stat_send_xoff = ProtoField.uint16("wut.com_stat.send_xoff", "send_xoff", nil, nil, 0x400)
com_stat_flush_rd = ProtoField.uint16("wut.com_stat.flush_rd", "flush_rd", nil, nil, 0x800)
com_stat_flush_wr = ProtoField.uint16("wut.com_stat.flush_wr", "flush_wr", nil, nil, 0x1000)
com_stat_set_rts_dtr = ProtoField.uint16("wut.com_stat.set_rts_dtr", "set_rts_dtr", nil, nil, 0x2000)
com_stat_set_break = ProtoField.uint16("wut.com_stat.set_break", "set_break", nil, nil, 0x4000)
com_stat_clear_break = ProtoField.uint16("wut.com_stat.clear_break", "clear_break", nil, nil, 0x8000)

com_stat_cbInQue = ProtoField.uint16("wut.com_stat.cbInQue", "cbInQue")
com_stat_cbOutQue = ProtoField.uint16("wut.com_stat.cbOutQue", "cbOutQue")

-- box_cntrl
-- box_cntrl_baud
box_cntrl_baud_baud = ProtoField.char("wut.cntrl_baud.baud", "baud", nil, baud_types, 0x1f)
box_cntrl_baud_fifo_aktiv = ProtoField.char("wut.cntrl_baud.fifo_aktiv", "fifo_aktiv", nil, nil, 0x20)
box_cntrl_baud_fifo = ProtoField.char("wut.cntrl_baud.fifo", "fifo", nil, nil, 0xc0)

-- box_cntrl_bits
box_cntrl_parity = ProtoField.uint8("wut.cntrl_baud.parity", "parity", nil, parity_types, 0x10)
box_cntrl_stop_bits = ProtoField.uint8("wut.cntrl_baud.stop_bits", "stop_bits", nil, stopbit_types, 0x4)
box_cntrl_data_bits = ProtoField.uint8("wut.cntrl_baud.data_bits", "data_bits", nil, databit_types, 0x3)

-- box_cntrl rls/cts/dsr timeout
box_cntrl_rls_time_out = ProtoField.uint16("wut.cntrl.rls_time_out", "rls_time_out")
box_cntrl_cts_time_out = ProtoField.uint16("wut.cntrl.cts_time_out", "cts_time_out")
box_cntrl_dsr_time_out = ProtoField.uint16("wut.cntrl.dsr_time_out", "dsr_time_out")


wut_protocol.fields = { zero_1, zero_2, -- start/end
						com_error_f_data, com_error_f_net, com_error_f_com, com_error_f_break, -- com_error
						com_error_f_cts_time, com_error_f_dsr_time, com_error_f_rlsd_time, com_error_f_overrun, -- com_error
						com_error_f_parity, com_error_f_frame, com_error_f_status, com_error_no_use_1, -- com_error
						com_error_no_use_2, com_error_f_rx_over, com_error_no_use_3, -- com_error
						com_stat_cts_hold, com_stat_dsr_hold, com_stat_ri_hold, com_stat_rlsd_hold, -- com_stat
						com_stat_dtr_hold, com_stat_rts_hold, com_stat_x_receive, com_stat_x_send, -- com_stat
						com_stat_break_mode, com_stat_dummy, com_stat_send_xoff, com_stat_flush_rd, -- com_stat
						com_stat_flush_wr, com_stat_set_rts_dtr, com_stat_set_break, com_stat_clear_break, -- com_stat
						com_stat_cbInQue, com_stat_cbOutQue, -- com_stat
						box_cntrl_baud_baud, box_cntrl_baud_fifo_aktiv, box_cntrl_baud_fifo, -- box_cntrl
						box_cntrl_parity, box_cntrl_stop_bits, box_cntrl_data_bits, -- box_cntrl_bits
						box_cntrl_rls_time_out, box_cntrl_cts_time_out, box_cntrl_dsr_time_out -- box_cntrl rls/cts/dsr timeout
}

function wut_protocol.dissector(buffer, pinfo, tree)
	length = buffer:len()
	if length ~= 30 then return end

	pinfo.cols.protocol = wut_protocol.name

	local subtree = tree:add(wut_protocol, buffer(), "WuT-Control Data")
	
	-- start char
	subtree:add(zero_1, buffer(0,1))
	
	-- com_error struct
	local com_error_subtree = subtree:add(wut_protocol, buffer(), "COM_ERROR")
	
	com_error_subtree:add(com_error_f_data, buffer(2,2))
	com_error_subtree:add(com_error_f_net, buffer(2,2))
	com_error_subtree:add(com_error_f_com, buffer(2,2))
	com_error_subtree:add(com_error_f_break, buffer(2,2))
	com_error_subtree:add(com_error_f_cts_time, buffer(2,2))
	com_error_subtree:add(com_error_f_dsr_time, buffer(2,2))
	com_error_subtree:add(com_error_f_rlsd_time, buffer(2,2))
	com_error_subtree:add(com_error_f_overrun, buffer(2,2))
	com_error_subtree:add(com_error_f_parity, buffer(2,2))
	com_error_subtree:add(com_error_f_frame, buffer(2,2))
	com_error_subtree:add(com_error_f_status, buffer(2,2))
	com_error_subtree:add(com_error_no_use_1, buffer(2,2))
	com_error_subtree:add(com_error_no_use_2, buffer(2,2))
	com_error_subtree:add(com_error_f_rx_over, buffer(2,2))
	com_error_subtree:add(com_error_no_use_3, buffer(2,2))
	
	-- com_stat
	local com_stat_subtree = subtree:add(wut_protocol, "_COM_STAT")
	
	com_stat_subtree:add(com_stat_cts_hold, buffer(4,1))
	com_stat_subtree:add(com_stat_dsr_hold, buffer(4,1))
	com_stat_subtree:add(com_stat_ri_hold, buffer(4,1))
	com_stat_subtree:add(com_stat_rlsd_hold, buffer(4,1))
	com_stat_subtree:add(com_stat_dtr_hold, buffer(4,1))
	com_stat_subtree:add(com_stat_rts_hold, buffer(4,1))
	com_stat_subtree:add(com_stat_x_receive, buffer(4,1))
	com_stat_subtree:add(com_stat_x_send, buffer(4,1))
	com_stat_subtree:add(com_stat_break_mode, buffer(4,1))
	com_stat_subtree:add(com_stat_dummy, buffer(4,1))
	com_stat_subtree:add(com_stat_send_xoff, buffer(4,1))
	com_stat_subtree:add(com_stat_flush_rd, buffer(4,1))
	com_stat_subtree:add(com_stat_flush_wr, buffer(4,1))
	com_stat_subtree:add(com_stat_set_rts_dtr, buffer(4,1))
	com_stat_subtree:add(com_stat_set_break, buffer(4,1))
	com_stat_subtree:add(com_stat_clear_break, buffer(4,1))
	
	com_stat_subtree:add(com_stat_cbInQue, buffer(5,2))
	com_stat_subtree:add(com_stat_cbOutQue, buffer(7,2))
	
	-- box_cntrl
	local box_cntrl_subtre = subtree:add(wut_protocol, "_BOX_CNTRL")
	
	-- baud
	
	box_cntrl_subtre:add(box_cntrl_baud_baud, buffer(9,1))
	box_cntrl_subtre:add(box_cntrl_baud_fifo_aktiv, buffer(9,1))
	box_cntrl_subtre:add(box_cntrl_baud_fifo, buffer(9,1))
	
	-- bits
	box_cntrl_subtre:add(box_cntrl_parity, buffer(10,1))
	box_cntrl_subtre:add(box_cntrl_stop_bits, buffer(10,1))
	box_cntrl_subtre:add(box_cntrl_data_bits, buffer(10,1))
	
	-- rls/cts/dsr timeout
	box_cntrl_subtre:add(box_cntrl_rls_time_out, buffer(11,1))
	box_cntrl_subtre:add(box_cntrl_cts_time_out, buffer(12,1))
	box_cntrl_subtre:add(box_cntrl_dsr_time_out, buffer(13,1))
	
	-- end char
	subtree:add(zero_1, buffer(29,1))

end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(9094, wut_protocol)
