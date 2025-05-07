let
  appearance = "transparent";
  opacity1 = "d0";
  opacity2 = "00";
  opacity3 = "cc";
  opacity4 = "10";
  opacity5 = "aa";
  opacity6 = "9bced6aa";
  opacity7 = "10";
  opacity8 = "22";
  opacity9 = "30";
  opacity10 = "10";
  opacity11 = "10";
  opacity12 = "e0";
  opacity13 = "9bced6aa";
in
{
  "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
  "name" = "Zed Legacy: Rosé Pine";
  "author" = "camdenboren";
  "themes" = [
    {
      "name" = "Zed Legacy: Rosé Pine Moon Transparent";
      "appearance" = "dark";
      "style" = {
        "background.appearance" = appearance;
        "border" = "#504c68ff";
        "border.variant" = "#322f48ff";
        "border.focused" = "#435255ff";
        "border.selected" = "#435255ff";
        "border.transparent" = "#00000000";
        "border.disabled" = "#44415bff";
        "elevated_surface.background" = "#28253c${opacity1}";
        "surface.background" = "#28253c${opacity2}";
        "background" = "#232136${opacity3}";
        "element.background" = "#28253c${opacity4}";
        "element.hover" = "#322f48${opacity5}";
        "element.active" = "#4f4b66ff";
        "element.selected" = "#4f4b66${opacity5}";
        "element.disabled" = "#28253cff";
        "drop_target.background" = "#85819e${opacity4}";
        "ghost_element.background" = "#00000000";
        "ghost_element.hover" = "#322f48${opacity4}";
        "ghost_element.active" = "#4f4b66ff";
        "ghost_element.selected" = "#4f4b66${opacity4}";
        "ghost_element.disabled" = "#28253cff";
        "text" = "#e0def4ff";
        "text.muted" = "#85819eff";
        "text.placeholder" = "#605d7aff";
        "text.disabled" = "#605d7aff";
        "text.accent" = "#9bced6ff";
        "icon" = "#e0def4ff";
        "icon.muted" = "#85819eff";
        "icon.disabled" = "#605d7aff";
        "icon.placeholder" = "#85819eff";
        "icon.accent" = "#9bced6ff";
        "status_bar.background" = "#38354e${opacity12}";
        "title_bar.background" = "#38354e${opacity12}";
        "title_bar.inactive_background" = "#28253c${opacity1}";
        "toolbar.background" = "#232136${opacity4}";
        "tab_bar.background" = "#28253c${opacity4}";
        "tab.inactive_background" = "#28253c${opacity2}";
        "tab.active_background" = "#232136${opacity4}";
        "search.match_background" = "#9cced766";
        "panel.background" = "#28253c${opacity2}";
        "panel.focused_border" = "#9bced6ff";
        "pane.focused_border" = null;
        "scrollbar.thumb.background" = "#e0def44c";
        "scrollbar.thumb.hover_background" = "#322f48ff";
        "scrollbar.thumb.border" = "#322f48ff";
        "scrollbar.track.background" = "#000000${opacity2}";
        "scrollbar.track.border" = "#27243bff";
        "editor.foreground" = "#e0def4ff";
        "editor.background" = "#232136${opacity4}";
        "editor.gutter.background" = "#232136${opacity4}";
        "editor.subheader.background" = "#28253c${opacity7}";
        "editor.active_line.background" = "#28253c${opacity9}";
        "editor.highlighted_line.background" = "#28253c${opacity8}";
        "editor.line_number" = "#6b697d";
        "editor.active_line_number" = "#d6d5dc";
        "editor.hover_line_number" = "#bbbac5";
        "editor.invisible" = "#595571ff";
        "editor.wrap_guide" = "#e0def40d";
        "editor.active_wrap_guide" = "#e0def41a";
        "editor.document_highlight.read_background" = "#9bced6${opacity10}";
        "editor.document_highlight.write_background" = "#595571${opacity11}";
        "terminal.background" = "#232136${opacity2}";
        "terminal.foreground" = "#e0def4ff";
        "terminal.bright_foreground" = "#e0def4ff";
        "terminal.dim_foreground" = "#232136ff";
        "terminal.ansi.black" = "#232136ff";
        "terminal.ansi.bright_black" = "#3f3b58ff";
        "terminal.ansi.dim_black" = "#e0def4ff";
        "terminal.ansi.red" = "#ea6e92ff";
        "terminal.ansi.bright_red" = "#7e3647ff";
        "terminal.ansi.dim_red" = "#fab9c6ff";
        "terminal.ansi.green" = "#5cc1a3ff";
        "terminal.ansi.bright_green" = "#31614fff";
        "terminal.ansi.dim_green" = "#b3e1d1ff";
        "terminal.ansi.yellow" = "#f6c177ff";
        "terminal.ansi.bright_yellow" = "#8a643aff";
        "terminal.ansi.dim_yellow" = "#fedfbbff";
        "terminal.ansi.blue" = "#9bced6ff";
        "terminal.ansi.bright_blue" = "#566b70ff";
        "terminal.ansi.dim_blue" = "#cfe7ebff";
        "terminal.ansi.magenta" = "#a683a0ff";
        "terminal.ansi.bright_magenta" = "#51414eff";
        "terminal.ansi.dim_magenta" = "#d2bfceff";
        "terminal.ansi.cyan" = "#3e8fb0ff";
        "terminal.ansi.bright_cyan" = "#264654ff";
        "terminal.ansi.dim_cyan" = "#a5c5d7ff";
        "terminal.ansi.white" = "#e0def4ff";
        "terminal.ansi.bright_white" = "#e0def4ff";
        "terminal.ansi.dim_white" = "#74708dff";
        "link_text.hover" = "#9bced6ff";
        "conflict" = "#f6c177ff";
        "conflict.background" = "#50331aff";
        "conflict.border" = "#6d4d2bff";
        "created" = "#5cc1a3ff";
        "created.background" = "#182d23ff";
        "created.border" = "#254839ff";
        "deleted" = "#ea6e92ff";
        "deleted.background" = "#431720ff";
        "deleted.border" = "#612834ff";
        "error" = "#ea6e92ff";
        "error.background" = "#431720ff";
        "error.border" = "#612834ff";
        "hidden" = "#605d7aff";
        "hidden.background" = "#38354eff";
        "hidden.border" = "#44415bff";
        "hint" = "#728aa2ff";
        "hint.background" = "#2f3639ff";
        "hint.border" = "#435255ff";
        "ignored" = "#605d7aff";
        "ignored.background" = "#38354eff";
        "ignored.border" = "#504c68ff";
        "info" = "#9bced6ff";
        "info.background" = "#2f3639ff";
        "info.border" = "#435255ff";
        "modified" = "#f6c177ff";
        "modified.background" = "#50331aff";
        "modified.border" = "#6d4d2bff";
        "predictive" = "#516b83ff";
        "predictive.background" = "#182d23ff";
        "predictive.border" = "#254839ff";
        "renamed" = "#9bced6ff";
        "renamed.background" = "#2f3639ff";
        "renamed.border" = "#435255ff";
        "success" = "#5cc1a3ff";
        "success.background" = "#182d23ff";
        "success.border" = "#254839ff";
        "unreachable" = "#85819eff";
        "unreachable.background" = "#38354eff";
        "unreachable.border" = "#504c68ff";
        "warning" = "#f6c177ff";
        "warning.background" = "#50331aff";
        "warning.border" = "#6d4d2bff";
        "players" = [
          {
            "cursor" = "#9bced6${opacity5}";
            "background" = "#${opacity13}";
            "selection" = "#${opacity6}";
          }
          {
            "cursor" = "#a683a0ff";
            "background" = "#a683a0ff";
            "selection" = "#a683a03d";
          }
          {
            "cursor" = "#c4a7e6ff";
            "background" = "#c4a7e6ff";
            "selection" = "#c4a7e63d";
          }
          {
            "cursor" = "#c4a7e6ff";
            "background" = "#c4a7e6ff";
            "selection" = "#c4a7e63d";
          }
          {
            "cursor" = "#3e8fb0ff";
            "background" = "#3e8fb0ff";
            "selection" = "#3e8fb03d";
          }
          {
            "cursor" = "#ea6e92ff";
            "background" = "#ea6e92ff";
            "selection" = "#ea6e923d";
          }
          {
            "cursor" = "#f6c177ff";
            "background" = "#f6c177ff";
            "selection" = "#f6c1773d";
          }
          {
            "cursor" = "#5cc1a3ff";
            "background" = "#5cc1a3ff";
            "selection" = "#5cc1a33d";
          }
        ];
        "syntax" = {
          "attribute" = {
            "color" = "#9bced6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "boolean" = {
            "color" = "#ea9a97ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "comment" = {
            "color" = "#6e6a86ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "comment.doc" = {
            "color" = "#8682a0ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "constant" = {
            "color" = "#5cc1a3ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "constructor" = {
            "color" = "#9bced6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "embedded" = {
            "color" = "#e0def4ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "emphasis" = {
            "color" = "#9bced6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "emphasis.strong" = {
            "color" = "#9bced6ff";
            "font_style" = null;
            "font_weight" = 700;
          };
          "enum" = {
            "color" = "#c4a7e6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "function" = {
            "color" = "#ea9a97ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "function.method" = {
            "color" = "#ea9a97ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "hint" = {
            "color" = "#728aa2ff";
            "font_style" = null;
            "font_weight" = 700;
          };
          "keyword" = {
            "color" = "#3d8fb0ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "label" = {
            "color" = "#9bced6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "link_text" = {
            "color" = "#9ccfd8ff";
            "font_style" = "normal";
            "font_weight" = null;
          };
          "link_uri" = {
            "color" = "#ea9a97ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "number" = {
            "color" = "#5cc1a3ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "operator" = {
            "color" = "#3d8fb0ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "predictive" = {
            "color" = "#516b83ff";
            "font_style" = "italic";
            "font_weight" = null;
          };
          "preproc" = {
            "color" = "#e0def4ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "primary" = {
            "color" = "#e0def4ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "property" = {
            "color" = "#9bced6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation" = {
            "color" = "#908caaff";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation.bracket" = {
            "color" = "#aeabc6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation.delimiter" = {
            "color" = "#aeabc6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation.list_marker" = {
            "color" = "#aeabc6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation.special" = {
            "color" = "#aeabc6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "string" = {
            "color" = "#f6c177ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "string.escape" = {
            "color" = "#8682a0ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "string.regex" = {
            "color" = "#c4a7e6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "string.special" = {
            "color" = "#c4a7e6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "string.special.symbol" = {
            "color" = "#c4a7e6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "tag" = {
            "color" = "#9ccfd8ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "text.literal" = {
            "color" = "#c4a7e6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "title" = {
            "color" = "#f6c177ff";
            "font_style" = null;
            "font_weight" = 700;
          };
          "type" = {
            "color" = "#9ccfd8ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "type.builtin" = {
            "color" = "#9ccfd8ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "variable" = {
            "color" = "#e0def4ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "variant" = {
            "color" = "#9bced6ff";
            "font_style" = null;
            "font_weight" = null;
          };
        };
      };
    }
  ];
}
