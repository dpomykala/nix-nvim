/*
POC
*/
_: {
  plugins.hydra = {
    enable = false;

    hydras = [
      {
        body = "[";
        heads = [
          [
            "b"
            "<Cmd>lua MiniBracketed.buffer('backward')<CR>"
            {desc = "  Buffer backward";}
          ]
          [
            "c"
            "<Cmd>lua MiniBracketed.comment('backward')<CR>"
            {desc = "  Comment backward";}
          ]
          [
            "w"
            "<Cmd>lua MiniBracketed.window('backward')<CR>"
            {desc = "  Window backward";}
          ]
        ];
        mode = "n";
      }
      {
        body = "]";
        heads = [
          [
            "b"
            "<Cmd>lua MiniBracketed.buffer('forward')<CR>"
            {desc = "  Buffer forward";}
          ]
          [
            "c"
            "<Cmd>lua MiniBracketed.comment('forward')<CR>"
            {desc = "  Comment forward";}
          ]
          [
            "w"
            "<Cmd>lua MiniBracketed.window('forward')<CR>"
            {desc = "  Window forward";}
          ]
        ];
        mode = "n";
      }
    ];

    settings = {
      # TODO: Add hint (in a status line?)
      hint = false;
    };
  };
}
