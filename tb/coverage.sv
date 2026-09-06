//-------------------------------------------------------------------------
// File        : coverage.sv
// Description : Tracks functional coverage to ensure all FIFO states
//               (full, empty, read, write) have been tested.
//-------------------------------------------------------------------------


class coverage;
  transaction trans;

  covergroup fifo_cg;
    option.per_instance = 1;

    cp_full: coverpoint trans.full {
      bins is_full     = {1};
      bins is_not_full = {0};
    }
    cp_empty: coverpoint trans.empty {
      bins is_empty     = {1};
      bins is_not_empty = {0};
    }
    cp_wr: coverpoint trans.wr_en {
      bins wr_active   = {1};
      bins wr_inactive = {0};
    }
    cp_rd: coverpoint trans.rd_en {
      bins rd_active   = {1};
      bins rd_inactive = {0};
    }

    cross cp_wr, cp_rd;

  endgroup

  function new();
    fifo_cg = new();
  endfunction

  function void sample(transaction t);
    // Update the local variable that the covergroup is pointing to 
    // before triggering the coverage collection
    this.trans = t;
    fifo_cg.sample();
  endfunction
endclass