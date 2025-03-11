// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`include "tb_uart_decimal.v"

`default_nettype none

`timescale 1 ns / 1 ps

module test_mixer_tb;
	reg clock;
	reg RSTB;
	reg CSB;
	reg power1, power2;
	reg power3, power4;

    wire gpio;
	wire uart_rx;
    wire [37:0] mprj_io;
	wire uart_pulse; //  Pulso salida UART
	
	wire [4:0] outs;
	assign outs =  mprj_io[12:8];  //Outs

	reg  toggle; 	 //  Pulso Schmitt trigger
	reg  [3:0] pulse_counter; // Inicializar el contador
	
	// Seleccion de valores
	assign uart_rx    =  mprj_io[6];  //Out
	assign mprj_io[7] =  toggle;	  //In
	assign uart_pulse =  mprj_io[35];  //Out



	
	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	//Clock
	always #12.5 clock <= (clock === 1'b0); //Frecuencia del clock 40 MHz
	//Pulso Schmitt Trigger
	always #500 toggle <= (toggle === 1'b0);// Frecuencia del pulso 1 MHz.
	
	initial begin
		clock  = 0;
		toggle = 0;
		pulse_counter = 3;
		//outs = 5'b00000
	end
		
	initial begin
		
		$dumpfile("test_mixer.vcd");
		$dumpvars(0, test_mixer_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (400) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		$display ("Monitor: Timeout, Test Mega-Project IO Ports (RTL) Failed");
		$display("%c[0m",27);
		$finish;
	end
	
	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;  // Force CSB high
		#2000;
		RSTB <= 1'b1;  // Release reset
		#170000;
		CSB = 1'b0;	   // CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	
	always @(posedge uart_pulse) begin
		pulse_counter <= pulse_counter - 1; // Decrementar el contador en cada pulso
		#1 $display("uart_pulse state = %b ", uart_pulse);
		$display("outs state = %b ", outs);
		if (pulse_counter == 0)// Contar 4 pulsos 
		begin
			wait(uart_pulse==1)
			wait(uart_pulse==0)
			wait(uart_pulse==1)
			$display("Fin Test");
			$finish;
		end
	end


	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	assign mprj_io[3] = 1;  // Force CSB high.
	assign mprj_io[0] = 0;  // Disable debug mode
	
	caravan uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (USER_VDD1V8),
		.vccd2	  (USER_VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        .mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("test_mixer.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);
	// Testbench UART
	tb_uart_decimal tb_uart_decimal (
		.ser_rx(uart_rx)
	);
endmodule
`default_nettype wire