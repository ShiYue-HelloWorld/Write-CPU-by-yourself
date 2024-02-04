module mycpu_top(
    input [5:0] ext_int,   //high active  //input

    input wire aclk,    
    input wire aresetn,   //low active

    output wire[3:0] arid,
    output wire[31:0] araddr,
    output wire[7:0] arlen,
    output wire[2:0] arsize,
    output wire[1:0] arburst,
    output wire[1:0] arlock,
    output wire[3:0] arcache,
    output wire[2:0] arprot,
    output wire arvalid,
    input wire arready,
                
    input wire[3:0] rid,
    input wire[31:0] rdata,
    input wire[1:0] rresp,
    input wire rlast,
    input wire rvalid,
    output wire rready, 
               
    output wire[3:0] awid,
    output wire[31:0] awaddr,
    output wire[7:0] awlen,
    output wire[2:0] awsize,
    output wire[1:0] awburst,
    output wire[1:0] awlock,
    output wire[3:0] awcache,
    output wire[2:0] awprot,
    output wire awvalid,
    input wire awready,
    
    output wire[3:0] wid,
    output wire[31:0] wdata,
    output wire[3:0] wstrb,
    output wire wlast,
    output wire wvalid,
    input wire wready,
    
    input wire[3:0] bid,
    input wire[1:0] bresp,
    input bvalid,
    output bready,

    //debug interface
    output wire[31:0] debug_wb_pc,
    output wire[3:0] debug_wb_rf_wen,
    output wire[4:0] debug_wb_rf_wnum,
    output wire[31:0] debug_wb_rf_wdata
);

// 涓?涓緥瀛?
//	wire [31:0] pc;
//	wire [31:0] instr;
//	wire memwrite;
//	wire [31:0] aluout, writedata, readdata;
//	wire [3:0] selM;    
//	wire [31:0] pcW;
//	wire regwriteW;
//	wire [4:0] writeregW;
//	wire [31:0] resultW;
//	wire no_dcache;
//	wire [31:0] data_sram_vaddr,inst_sram_vaddr;
//	wire flush_except;
//	wire memenM;
//	wire i_stall,d_stall; //类sram的stall
//    wire [31:0] debug_wb_pc;
//    wire [3 :0] debug_wb_rf_wen;
//    wire [4 :0] debug_wb_rf_wnum;
//    wire [31:0] debug_wb_rf_wdata;
    
    
//    //inst_sram
//    wire inst_sram_en;
//    wire [3 :0] inst_sram_wen;
//    wire [31:0] inst_sram_addr;
//    wire [31:0] inst_sram_wdata;
//    wire [31:0] inst_sram_rdata;
    
//    //data_sram
//    wire data_sram_en;
//    wire [3 :0] data_sram_wen;
//    wire [31:0] data_sram_addr;
//    wire [31:0] data_sram_wdata;
//    wire [31:0] data_sram_rdata;
    
//    mips mips(
//        .clk(~clk),
//        .rst(~resetn),
//        .ext_int(ext_int),
//        //instr
//        // .inst_en(inst_en),
//        .pcF(pc),             
//        .instrF(instr),              
//        //data
//        // .data_en(data_en),
//        .memwriteM(memwrite),
//        .aluoutM(aluout),
//        .writedataM(writedata),
//        .readdataM(readdata),
//        .selM(selM),
//        .regwriteW(regwriteW),
//        .writeregW(writeregW),
//        .resultW(resultW),
//        .pcW(pcW),
//        .flush_except(flush_except),
//        .memenM(memenM)
//    );

    wire clk, rst;
    assign clk = aclk;
    assign rst = ~aresetn;
    
    wire        cpu_inst_req  ;
    wire [31:0] cpu_inst_addr ;
    wire        cpu_inst_wr   ;
    wire [1:0]  cpu_inst_size ;
    wire [31:0] cpu_inst_wdata;
    wire [31:0] cpu_inst_rdata;
    wire        cpu_inst_addr_ok;
    wire        cpu_inst_data_ok;
    
    wire        cpu_data_req  ;
    wire [31:0] cpu_data_addr ;
    wire        cpu_data_wr   ;
    wire [1:0]  cpu_data_size ;
    wire [31:0] cpu_data_wdata;
    wire [31:0] cpu_data_rdata;
    wire        cpu_data_addr_ok;
    wire        cpu_data_data_ok;
    
    wire        cache_inst_req  ;
    wire [31:0] cache_inst_addr ;
    wire        cache_inst_wr   ;
    wire [1:0]  cache_inst_size ;
    wire [31:0] cache_inst_wdata;
    wire [31:0] cache_inst_rdata;
    wire        cache_inst_addr_ok;
    wire        cache_inst_data_ok;
    
    wire        cache_data_req  ;
    wire [31:0] cache_data_addr ;
    wire        cache_data_wr   ;
    wire [1:0]  cache_data_size ;
    wire [31:0] cache_data_wdata;
    wire [31:0] cache_data_rdata;
    wire        cache_data_addr_ok;
    wire        cache_data_data_ok;
    
    wire        ram_data_req  ;
    wire [31:0] ram_data_addr ;
    wire        ram_data_wr   ;
    wire [1:0]  ram_data_size ;
    wire [31:0] ram_data_wdata;
    wire [31:0] ram_data_rdata;
    wire        ram_data_addr_ok;
    wire        ram_data_data_ok;
    
    wire        conf_data_req  ;
    wire [31:0] conf_data_addr ;
    wire        conf_data_wr   ;
    wire [1:0]  conf_data_size ;
    wire [31:0] conf_data_wdata;
    wire [31:0] conf_data_rdata;
    wire        conf_data_addr_ok;
    wire        conf_data_data_ok;
    
    wire        wrap_data_req  ;
    wire [31:0] wrap_data_addr ;
    wire        wrap_data_wr   ;
    wire [1:0]  wrap_data_size ;
    wire [31:0] wrap_data_wdata;
    wire [31:0] wrap_data_rdata;
    wire        wrap_data_addr_ok;
    wire        wrap_data_data_ok;

    mips mips(
    .clk(clk), .rst(rst),
    .ext_int(ext_int),

    .inst_req     (cpu_inst_req  ),
    .inst_wr      (cpu_inst_wr   ),
    .inst_addr    (cpu_inst_addr ),
    .inst_size    (cpu_inst_size ),
    .inst_wdata   (cpu_inst_wdata),
    .inst_rdata   (cpu_inst_rdata),
    .inst_addr_ok (cpu_inst_addr_ok),
    .inst_data_ok (cpu_inst_data_ok),

    .data_req     (cpu_data_req  ),
    .data_wr      (cpu_data_wr   ),
    .data_addr    (cpu_data_addr ),
    .data_wdata   (cpu_data_wdata),
    .data_size    (cpu_data_size ),
    .data_rdata   (cpu_data_rdata),
    .data_addr_ok (cpu_data_addr_ok),
    .data_data_ok (cpu_data_data_ok),

    .debug_wb_pc       (debug_wb_pc       ),
    .debug_wb_rf_wen   (debug_wb_rf_wen   ),
    .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
    .debug_wb_rf_wdata (debug_wb_rf_wdata )
);
    
    wire [31:0] cpu_inst_paddr;
    wire [31:0] cpu_data_paddr;
    wire no_dcache;

    //mmu:虚拟地址到物理地址的转换
    mmu mmu(
        .inst_vaddr(cpu_inst_addr ),
        .inst_paddr(cpu_inst_paddr),
        .data_vaddr(cpu_data_addr ),
        .data_paddr(cpu_data_paddr),
        .no_dcache (no_dcache)
    );
    
//    bridge_1x2 bridge_1x2(
//    .no_dcache        (no_dcache    ),

//    .cpu_data_req     (cpu_data_req  ),
//    .cpu_data_wr      (cpu_data_wr   ),
//    .cpu_data_addr    (cpu_data_paddr ),   
//    .cpu_data_wdata   (cpu_data_wdata),
//    .cpu_data_size    (cpu_data_size ),
//    .cpu_data_rdata   (cpu_data_rdata),
//    .cpu_data_addr_ok (cpu_data_addr_ok),
//    .cpu_data_data_ok (cpu_data_data_ok),

//    .ram_data_req     (ram_data_req  ),
//    .ram_data_wr      (ram_data_wr   ),
//    .ram_data_addr    (ram_data_addr ),
//    .ram_data_wdata   (ram_data_wdata),
//    .ram_data_size    (ram_data_size ),
//    .ram_data_rdata   (ram_data_rdata),
//    .ram_data_addr_ok (ram_data_addr_ok),
//    .ram_data_data_ok (ram_data_data_ok),

//    .conf_data_req     (conf_data_req  ),
//    .conf_data_wr      (conf_data_wr   ),
//    .conf_data_addr    (conf_data_addr ),
//    .conf_data_wdata   (conf_data_wdata),
//    .conf_data_size    (conf_data_size ),
//    .conf_data_rdata   (conf_data_rdata),
//    .conf_data_addr_ok (conf_data_addr_ok),
//    .conf_data_data_ok (conf_data_data_ok)
//);
        //指令cache
        i_cache i_cache(
        .clk(clk), .rst(rst),
        .cpu_inst_req     (cpu_inst_req     ),
        .cpu_inst_wr      (cpu_inst_wr      ),
        .cpu_inst_size    (cpu_inst_size    ),
        .cpu_inst_addr    (cpu_inst_paddr    ),
        .cpu_inst_wdata   (cpu_inst_wdata   ),
        .cpu_inst_rdata   (cpu_inst_rdata   ),
        .cpu_inst_addr_ok (cpu_inst_addr_ok ),
        .cpu_inst_data_ok (cpu_inst_data_ok ),

        .cache_inst_req     (cache_inst_req     ),
        .cache_inst_wr      (cache_inst_wr      ),
        .cache_inst_size    (cache_inst_size    ),
        .cache_inst_addr    (cache_inst_addr    ),
        .cache_inst_wdata   (cache_inst_wdata   ),
        .cache_inst_rdata   (cache_inst_rdata   ),
        .cache_inst_addr_ok (cache_inst_addr_ok ),
        .cache_inst_data_ok (cache_inst_data_ok )
    );
    
    
    cpu_axi_interface cpu_axi_interface(
    .clk(clk),
    .resetn(~rst),

    .inst_req       (cache_inst_req  ),
    .inst_wr        (cache_inst_wr   ),
    .inst_size      (cache_inst_size ),
    .inst_addr      (cache_inst_addr ),
    .inst_wdata     (cache_inst_wdata),
    .inst_rdata     (cache_inst_rdata),
    .inst_addr_ok   (cache_inst_addr_ok),
    .inst_data_ok   (cache_inst_data_ok),

    .data_req       (cpu_data_req  ),
    .data_wr        (cpu_data_wr   ),
    .data_size      (cpu_data_size ),
    .data_addr      (cpu_data_paddr ),
    .data_wdata     (cpu_data_wdata ),
    .data_rdata     (cpu_data_rdata),
    .data_addr_ok   (cpu_data_addr_ok),
    .data_data_ok   (cpu_data_data_ok),

    .arid(arid),
    .araddr(araddr),
    .arlen(arlen),
    .arsize(arsize),
    .arburst(arburst),
    .arlock(arlock),
    .arcache(arcache),
    .arprot(arprot),
    .arvalid(arvalid),
    .arready(arready),

    .rid(rid),
    .rdata(rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready),

    .awid(awid),
    .awaddr(awaddr),
    .awlen(awlen),
    .awsize(awsize),
    .awburst(awburst),
    .awlock(awlock),
    .awcache(awcache),
    .awprot(awprot),
    .awvalid(awvalid),
    .awready(awready),

    .wid(wid),
    .wdata(wdata),
    .wstrb(wstrb),
    .wlast(wlast),
    .wvalid(wvalid),
    .wready(wready),

    .bid(bid),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready)
);


    
    
//    //cache
//    cache cache(
//    .clk(clk), .rst(rst),
//    .cpu_inst_req     (cpu_inst_req  ),
//    .cpu_inst_wr      (cpu_inst_wr   ),
//    .cpu_inst_addr    (cpu_inst_paddr ),  
//    .cpu_inst_size    (cpu_inst_size ),
//    .cpu_inst_wdata   (cpu_inst_wdata),
//    .cpu_inst_rdata   (cpu_inst_rdata),
//    .cpu_inst_addr_ok (cpu_inst_addr_ok),
//    .cpu_inst_data_ok (cpu_inst_data_ok),

//    .cpu_data_req     (ram_data_req  ),
//    .cpu_data_wr      (ram_data_wr   ),
//    .cpu_data_addr    (ram_data_addr ),
//    .cpu_data_wdata   (ram_data_wdata),
//    .cpu_data_size    (ram_data_size ),
//    .cpu_data_rdata   (ram_data_rdata),
//    .cpu_data_addr_ok (ram_data_addr_ok),
//    .cpu_data_data_ok (ram_data_data_ok),

//    .cache_inst_req     (cache_inst_req  ),
//    .cache_inst_wr      (cache_inst_wr   ),
//    .cache_inst_addr    (cache_inst_addr ),
//    .cache_inst_size    (cache_inst_size ),
//    .cache_inst_wdata   (cache_inst_wdata),
//    .cache_inst_rdata   (cache_inst_rdata),
//    .cache_inst_addr_ok (cache_inst_addr_ok),
//    .cache_inst_data_ok (cache_inst_data_ok),

//    .cache_data_req     (cache_data_req  ),
//    .cache_data_wr      (cache_data_wr   ),
//    .cache_data_addr    (cache_data_addr ),
//    .cache_data_wdata   (cache_data_wdata),
//    .cache_data_size    (cache_data_size ),
//    .cache_data_rdata   (cache_data_rdata),
//    .cache_data_addr_ok (cache_data_addr_ok),
//    .cache_data_data_ok (cache_data_data_ok)
//);

//    bridge_2x1 bridge_2x1(
//    .no_dcache        (no_dcache    ),

//    .ram_data_req     (cache_data_req  ),
//    .ram_data_wr      (cache_data_wr   ),
//    .ram_data_addr    (cache_data_addr ),
//    .ram_data_wdata   (cache_data_wdata),
//    .ram_data_size    (cache_data_size ),
//    .ram_data_rdata   (cache_data_rdata),
//    .ram_data_addr_ok (cache_data_addr_ok),
//    .ram_data_data_ok (cache_data_data_ok),

//    .conf_data_req     (conf_data_req  ),
//    .conf_data_wr      (conf_data_wr   ),
//    .conf_data_addr    (conf_data_addr ),
//    .conf_data_wdata   (conf_data_wdata),
//    .conf_data_size    (conf_data_size ),
//    .conf_data_rdata   (conf_data_rdata),
//    .conf_data_addr_ok (conf_data_addr_ok),
//    .conf_data_data_ok (conf_data_data_ok),

//    .wrap_data_req     (wrap_data_req  ),
//    .wrap_data_wr      (wrap_data_wr   ),
//    .wrap_data_addr    (wrap_data_addr ),
//    .wrap_data_wdata   (wrap_data_wdata),
//    .wrap_data_size    (wrap_data_size ),
//    .wrap_data_rdata   (wrap_data_rdata),
//    .wrap_data_addr_ok (wrap_data_addr_ok),
//    .wrap_data_data_ok (wrap_data_data_ok)
//);

//    cpu_axi_interface cpu_axi_interface(
//    .clk(clk),
//    .resetn(~rst),

//    .inst_req       (cache_inst_req  ),
//    .inst_wr        (cache_inst_wr   ),
//    .inst_size      (cache_inst_size ),
//    .inst_addr      (cache_inst_addr ),
//    .inst_wdata     (cache_inst_wdata),
//    .inst_rdata     (cache_inst_rdata),
//    .inst_addr_ok   (cache_inst_addr_ok),
//    .inst_data_ok   (cache_inst_data_ok),

//    .data_req       (wrap_data_req  ),
//    .data_wr        (wrap_data_wr   ),
//    .data_size      (wrap_data_size ),
//    .data_addr      (wrap_data_addr ),
//    .data_wdata     (wrap_data_wdata ),
//    .data_rdata     (wrap_data_rdata),
//    .data_addr_ok   (wrap_data_addr_ok),
//    .data_data_ok   (wrap_data_data_ok),

//    .arid(arid),
//    .araddr(araddr),
//    .arlen(arlen),
//    .arsize(arsize),
//    .arburst(arburst),
//    .arlock(arlock),
//    .arcache(arcache),
//    .arprot(arprot),
//    .arvalid(arvalid),
//    .arready(arready),

//    .rid(rid),
//    .rdata(rdata),
//    .rresp(rresp),
//    .rlast(rlast),
//    .rvalid(rvalid),
//    .rready(rready),

//    .awid(awid),
//    .awaddr(awaddr),
//    .awlen(awlen),
//    .awsize(awsize),
//    .awburst(awburst),
//    .awlock(awlock),
//    .awcache(awcache),
//    .awprot(awprot),
//    .awvalid(awvalid),
//    .awready(awready),

//    .wid(wid),
//    .wdata(wdata),
//    .wstrb(wstrb),
//    .wlast(wlast),
//    .wvalid(wvalid),
//    .wready(wready),

//    .bid(bid),
//    .bresp(bresp),
//    .bvalid(bvalid),
//    .bready(bready)
//);


    


endmodule