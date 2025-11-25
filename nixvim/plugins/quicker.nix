_: {
  plugins.quicker = {
    enable = true;

    settings = {
      keys = [
        {
          __unkeyed-1 = ">";
          __unkeyed-2.__raw = ''
            function()
              require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
            end
          '';
          desc = "Expand quickfix context";
        }
        {
          __unkeyed-1 = "<";
          __unkeyed-2.__raw = "require('quicker').collapse";
          desc = "Collapse quickfix context";
        }
      ];
    };
  };
}
