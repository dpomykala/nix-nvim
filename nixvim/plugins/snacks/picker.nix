{
  config,
  lib,
  ...
}: {
  plugins.snacks.settings.picker = let
    deltaFeatures =
      if config.colorschemes.catppuccin.enable
      then "catppuccin-${config.colorschemes.catppuccin.settings.flavour}"
      else "";
  in {
    enabled = true;

    actions = lib.optionalAttrs config.plugins.persistence.enable {
      # Custom picker action to load session using persistence.nvim
      # This is a modified version of the `load_session` action from snacks.picker
      load_persistence_session.__raw = ''
        function(picker, item)
          -- Original implementation
          -- https://github.com/folke/snacks.nvim/blob/bc0630e43be5699bb94dadc302c0d21615421d93/lua/snacks/picker/actions.lua#L544-L561
          picker:close()
          if not item then
            return
          end
          local dir = item.file
          local session_loaded = false
          vim.api.nvim_create_autocmd("SessionLoadPost", {
            once = true,
            callback = function()
              session_loaded = true
            end,
          })
          vim.defer_fn(function()
            if not session_loaded then
              Snacks.picker.files()
            end
          end, 100)
          vim.fn.chdir(dir)

          -- Modified part - try to restore session using persistence.nvim
          require("persistence").load()
        end
      '';
    };

    # Use delta for previewing diffs and Git output
    # NOTE: Requires delta to be installed and configured
    previewers = {
      diff = {
        builtin = false;
        cmd = ["delta" "--features" deltaFeatures];
      };
      git = {
        builtin = false;
        args = ["-c" "delta.line-numbers=false"];
      };
    };

    sources = lib.optionalAttrs config.plugins.persistence.enable {
      projects.confirm = "load_persistence_session";
      zoxide.confirm = "load_persistence_session";
    };
  };

  # NOTE: Some picker keymaps may be defined in other places (e.g. LSP config)
  keymaps = let
    inherit (lib.custom.nixvim) nCmdMap nxCmdMap;
  in [
    (nCmdMap {
      key = "<Leader>fa";
      cmd = "lua Snacks.picker.autocmds()";
      desc = "Autocommands";
    })
    (nCmdMap {
      key = "<Leader>fb";
      cmd = "lua Snacks.picker.buffers()";
      desc = "Buffers";
    })
    (nCmdMap {
      key = "<Leader>fC";
      cmd = "lua Snacks.picker.colorschemes()";
      desc = "Colorschemes";
    })
    (nCmdMap {
      key = "<Leader>fc";
      cmd = "lua Snacks.picker.commands()";
      desc = "Commands";
    })
    (nCmdMap {
      key = "<Leader>fD";
      cmd = "lua Snacks.picker.diagnostics()";
      desc = "Diagnostics (cwd)";
    })
    (nCmdMap {
      key = "<Leader>fd";
      cmd = "lua Snacks.picker.diagnostics_buffer()";
      desc = "Diagnostics (buffer)";
    })
    (nCmdMap {
      key = "<Leader>fF";
      cmd = "lua Snacks.picker.files()";
      desc = "Files";
    })
    (nCmdMap {
      key = "<Leader>ff";
      cmd = "lua Snacks.picker.smart()";
      desc = "Files (smart)";
    })
    (nCmdMap {
      key = "<Leader>fg";
      cmd = "lua Snacks.picker.grep()";
      desc = "Grep";
    })
    (nCmdMap {
      key = "<Leader>fH";
      cmd = "lua Snacks.picker.highlights()";
      desc = "Highlights";
    })
    (nCmdMap {
      key = "<Leader>fh";
      cmd = "lua Snacks.picker.help()";
      desc = "Help";
    })
    (nCmdMap {
      key = "<Leader>fi";
      cmd = "lua Snacks.picker.icons()";
      desc = "Icons";
    })
    (nCmdMap {
      key = "<Leader>fj";
      cmd = "lua Snacks.picker.jumps()";
      desc = "Jumps";
    })
    (nCmdMap {
      key = "<Leader>fk";
      cmd = "lua Snacks.picker.keymaps()";
      desc = "Keymaps";
    })
    (nCmdMap {
      key = "<Leader>fL";
      cmd = "lua Snacks.picker.loclist()";
      desc = "Location list";
    })
    (nCmdMap {
      key = "<Leader>fl";
      cmd = "lua Snacks.picker.lines()";
      desc = "Buffer lines";
    })
    (nCmdMap {
      key = "<Leader>fm";
      cmd = "lua Snacks.picker.man()";
      desc = "Man pages";
    })
    (nCmdMap {
      key = "<Leader>fn";
      cmd = "lua Snacks.picker.notifications()";
      desc = "Notifications";
    })
    (nCmdMap {
      key = "<Leader>fo";
      cmd = "lua Snacks.picker.grep_buffers()";
      desc = "Grep (open buffers)";
    })
    (nCmdMap {
      key = "<Leader>fP";
      cmd = "lua Snacks.picker.pickers()";
      desc = "Pickers";
    })
    (nCmdMap {
      key = "<Leader>fp";
      cmd = "lua Snacks.picker.projects()";
      desc = "Projects";
    })
    (nCmdMap {
      key = "<Leader>fq";
      cmd = "lua Snacks.picker.qflist()";
      desc = "Quickfix list";
    })
    (nCmdMap {
      key = "<Leader>fr";
      cmd = "lua Snacks.picker.recent()";
      desc = "Recent files";
    })
    (nCmdMap {
      key = "<Leader>fs";
      cmd = "lua Snacks.picker.spelling()";
      desc = "Spelling";
    })
    (nCmdMap {
      key = "<Leader>fu";
      cmd = "lua Snacks.picker.undo()";
      desc = "Undotree";
    })
    (nxCmdMap {
      key = "<Leader>fw";
      cmd = "lua Snacks.picker.grep_word()";
      desc = "Grep for word(s)";
    })
    (nCmdMap {
      key = "<Leader>fz";
      cmd = "lua Snacks.picker.zoxide()";
      desc = "Files (zoxide)";
    })
    (nCmdMap {
      key = "<Leader>f\"";
      cmd = "lua Snacks.picker.registers()";
      desc = "Registers";
    })
    (nCmdMap {
      key = "<Leader>f'";
      cmd = "lua Snacks.picker.marks()";
      desc = "Marks";
    })
    (nCmdMap {
      key = "<Leader>f.";
      cmd = "lua Snacks.picker.resume()";
      desc = "Resume";
    })
    (nCmdMap {
      key = "<Leader>f/";
      cmd = "lua Snacks.picker.search_history()";
      desc = "Search history";
    })
    (nCmdMap {
      key = "<Leader>f;";
      cmd = "lua Snacks.picker.command_history()";
      desc = "Command history";
    })

    # Git

    (nCmdMap {
      key = "<Leader>gb";
      cmd = "lua Snacks.picker.git_branches()";
      desc = "Branches";
    })
    (nCmdMap {
      key = "<Leader>gL";
      cmd = "lua Snacks.picker.git_log_line()";
      desc = "Log (line)";
    })
    (nCmdMap {
      key = "<Leader>gl";
      cmd = "lua Snacks.picker.git_log()";
      desc = "Log";
    })
    (nCmdMap {
      key = "<Leader>gS";
      cmd = "lua Snacks.picker.git_stash()";
      desc = "Stash";
    })
    (nCmdMap {
      key = "<Leader>gs";
      cmd = "lua Snacks.picker.git_status()";
      desc = "Status";
    })
    (nCmdMap {
      key = "<Leader>gd";
      cmd = "lua Snacks.picker.git_diff()";
      desc = "Diff (hunks)";
    })
    (nCmdMap {
      key = "<Leader>gf";
      cmd = "lua Snacks.picker.git_log_file()";
      desc = "Log (file)";
    })
  ];
}
