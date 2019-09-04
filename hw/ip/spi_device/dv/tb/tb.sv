// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
module tb;
  // dep packages
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import tl_agent_pkg::*;
  import spi_device_env_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  wire clk, rst_n;
  wire [NUM_MAX_INTERRUPTS-1:0] interrupts;
  wire [NUM_MAX_ALERTS-1:0] alerts;

  wire sck;
  wire csb;
  wire miso_o;
  wire miso_en;
  wire mosi_i;

  wire intr_rxf;
  wire intr_rxlvl;
  wire intr_txlvl;
  wire intr_rxerr;

  // interfaces
  clk_rst_if clk_rst_if(.clk(clk), .rst_n(rst_n));
  pins_if #(NUM_MAX_INTERRUPTS) intr_if(.pins(interrupts));
  pins_if #(NUM_MAX_ALERTS) alerts_if(.pins(alerts));
  tl_if tl_if(.clk(clk), .rst_n(rst_n));
  spi_if spi_if(.rst_n(rst_n));

  // dut
  spi_device dut (
    .clk_i          (clk       ),
    .rst_ni         (rst_n     ),

    .tl_i           (tl_if.h2d ),
    .tl_o           (tl_if.d2h ),

    .cio_sck_i      (sck       ),
    .cio_csb_i      (csb       ),
    .cio_miso_o     (miso_o    ),
    .cio_miso_en_o  (miso_en   ),
    .cio_mosi_i     (mosi_i    ),

    .intr_rxf_o     (intr_rxf  ),
    .intr_rxlvl_o   (intr_rxlvl),
    .intr_txlvl_o   (intr_txlvl),
    .intr_rxerr_o   (intr_rxerr)
  );

  assign sck          = spi_if.sck;
  assign csb          = spi_if.csb;
  assign mosi_i       = spi_if.mosi;
  assign spi_if.miso  = miso_en ? miso_o : 1'bz;

  assign interrupts[RxFifoFull]     = intr_rxf  ;
  assign interrupts[RxFifoGtLevel]  = intr_rxlvl;
  assign interrupts[TxFifoLtLevel]  = intr_txlvl;
  assign interrupts[RxFwModeErr]    = intr_rxerr;

  initial begin
    // drive clk and rst_n from clk_if
    clk_rst_if.set_active();
    uvm_config_db#(virtual clk_rst_if)::set(null, "*.env", "clk_rst_vif", clk_rst_if);
    uvm_config_db#(intr_vif)::set(null, "*.env", "intr_vif", intr_if);
    uvm_config_db#(alerts_vif)::set(null, "*.env", "alerts_vif", alerts_if);
    uvm_config_db#(virtual tl_if)::set(null, "*.env.m_tl_agent*", "vif", tl_if);
    uvm_config_db#(virtual spi_if)::set(null, "*.env.m_spi_agent*", "vif", spi_if);
    $timeformat(-12, 0, " ps", 12);
    run_test();
  end

endmodule