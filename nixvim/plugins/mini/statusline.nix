_: {
  plugins.mini.modules.statusline = {
    content.active.__raw = ''
      function()
        local mode, mode_hl = MiniStatusline.section_mode({trunc_width = 120})
        local git = MiniStatusline.section_git({trunc_width = 40})
        local diff = MiniStatusline.section_diff({trunc_width = 75})
        local diagnostics = MiniStatusline.section_diagnostics({trunc_width = 75})
        local lsp = MiniStatusline.section_lsp({trunc_width = 75})
        local filename = MiniStatusline.section_filename({trunc_width = 140})
        local fileinfo = MiniStatusline.section_fileinfo({trunc_width = 120})
        local location = MiniStatusline.section_location({trunc_width = 75})
        local search = MiniStatusline.section_searchcount({trunc_width = 75})

        -- ui2 doesn't show the "recording" text while 'cmdheight' is 0
        local register = vim.fn.reg_recording()
        local recording = register ~= "" and "recording @" .. register or ""

        return MiniStatusline.combine_groups({
          {hl = mode_hl, strings = {mode}},
          {hl = "MiniStatuslineDevinfo", strings = {git, diff, diagnostics, lsp}},
          "%<", -- Mark general truncate point
          {hl = "MiniStatuslineFilename", strings = {filename}},
          "%=", -- End left alignment
          {hl = "MiniStatuslineFilename", strings = {recording}},
          "%S ", -- Pending keys, when 'showcmdloc' is "statusline"
          {hl = "MiniStatuslineFileinfo", strings = {fileinfo}},
          {hl = mode_hl, strings = {search, location}},
        })
      end
    '';
  };

  # Starting or stopping a recording doesn't redraw the statusline. During
  # RecordingLeave, `reg_recording()` still returns the register, so wait.
  autoCmd = [
    {
      event = [
        "RecordingEnter"
        "RecordingLeave"
      ];
      callback.__raw = "function() vim.schedule(vim.cmd.redrawstatus) end";
      desc = "Redraw the statusline for the recording indicator";
    }
  ];
}
