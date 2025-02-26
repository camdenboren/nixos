{ system, lib }:

let
  isDarwin = lib.hasSuffix "-darwin" system;
  appearance = if isDarwin then "transparent" else "opaque";
  opacity1 = if isDarwin then "d0" else "ff";
  opacity2 = if isDarwin then "00" else "ff";
  opacity3 = if isDarwin then "cc" else "ff";
  opacity4 = if isDarwin then "10" else "ff";
  opacity5 = if isDarwin then "aa" else "ff";
  opacity6 = if isDarwin then "750000aa" else "9700003d";
  opacity7 = if isDarwin then "10" else "33";
  opacity8 = if isDarwin then "22" else "33";
  opacity9 = if isDarwin then "30" else "ff";
  opacity10 = if isDarwin then "10" else "1a";
  opacity11 = if isDarwin then "10" else "66";
  opacity12 = if isDarwin then "e0" else "ff";
  opacity13 = if isDarwin then "750000aa" else "970000ff";
in
{
  "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
  "name" = "Red";
  "author" = "camdenboren";
  "themes" = [
    {
      "name" = "Red";
      "appearance" = "dark";
      "style" = {
        "background.appearance" = appearance;
        "accents" = [ ];
        "border" = "#6e2c2fff";
        "border.variant" = "#460505ff";
        "border.focused" = "#501b1bff";
        "border.selected" = "#501b1bff";
        "border.transparent" = "#00000000";
        "border.disabled" = "#501919ff";
        "elevated_surface.background" = "#330000${opacity1}";
        "surface.background" = "#450000${opacity2}";
        "background" = "#390000${opacity3}";
        "element.background" = "#883333${opacity4}";
        "element.hover" = "#800000${opacity5}";
        "element.active" = null;
        "element.selected" = "#880000${opacity5}";
        "element.disabled" = null;
        "drop_target.background" = "#662222${opacity4}";
        "ghost_element.background" = null;
        "ghost_element.hover" = "#800000${opacity4}";
        "ghost_element.active" = null;
        "ghost_element.selected" = "#880000${opacity4}";
        "ghost_element.disabled" = null;
        "text" = "#f4ededff";
        "text.muted" = "#918787ff";
        "text.placeholder" = "#7e7373ff";
        "text.disabled" = "#7e7373ff";
        "text.accent" = "#da6464ff";
        "icon" = "#f4ededff";
        "icon.muted" = "#918787ff";
        "icon.disabled" = "#7e7373ff";
        "icon.placeholder" = "#918787ff";
        "icon.accent" = "#da6464ff";
        "status_bar.background" = "#700000${opacity12}";
        "title_bar.background" = "#700000${opacity12}";
        "title_bar.inactive_background" = "#590000${opacity1}";
        "toolbar.background" = "#390000${opacity4}";
        "tab_bar.background" = "#330000${opacity4}";
        "tab.inactive_background" = "#300a0a${opacity2}";
        "tab.active_background" = "#490000${opacity4}";
        "search.match_background" = null;
        "panel.background" = "#450000${opacity2}";
        "panel.focused_border" = "#6e2c2fff";
        "panel.indent_guide" = "#918787ff";
        "panel.indent_guide_active" = "#a69b9bff";
        "panel.indent_guide_hover" = "#a69b9bff";
        "pane.focused_border" = null;
        "scrollbar.thumb.background" = null;
        "scrollbar.thumb.hover_background" = null;
        "scrollbar.thumb.border" = "#220000";
        "scrollbar.track.background" = "#390000${opacity2}";
        "scrollbar.track.border" = "#460505ff";
        "editor.foreground" = "#f8f8f8";
        "editor.background" = "#390000${opacity4}";
        "editor.gutter.background" = "#390000${opacity4}";
        "editor.subheader.background" = "#ff0000${opacity7}";
        "editor.active_line.background" = "#580000${opacity9}";
        "editor.highlighted_line.background" = "#ff0000${opacity8}";
        "editor.line_number" = "#ff777788";
        "editor.active_line_number" = "#ffbbbb88";
        "editor.invisible" = null;
        "editor.wrap_guide" = null;
        "editor.active_wrap_guide" = null;
        "editor.indent_guide" = "#cc0000";
        "editor.indent_guide_active" = "#EA1E1E";
        "editor.document_highlight.read_background" = "#d72828${opacity10}";
        "editor.document_highlight.write_background" = "#8c6e6e${opacity11}";
        "editor.document_highlight.bracket_background" = "#970000${opacity4}";
        "terminal.background" = "#390000${opacity2}";
        "terminal.foreground" = null;
        "terminal.ansi.background" = null;
        "terminal.bright_foreground" = null;
        "terminal.dim_foreground" = null;
        "terminal.ansi.black" = "#000000";
        "terminal.ansi.bright_black" = "#666666";
        "terminal.ansi.dim_black" = null;
        "terminal.ansi.red" = "#cd3131";
        "terminal.ansi.bright_red" = "#f14c4c";
        "terminal.ansi.dim_red" = null;
        "terminal.ansi.green" = "#0dbc79";
        "terminal.ansi.bright_green" = "#23d18b";
        "terminal.ansi.dim_green" = null;
        "terminal.ansi.yellow" = "#e5e510";
        "terminal.ansi.bright_yellow" = "#f5f543";
        "terminal.ansi.dim_yellow" = null;
        "terminal.ansi.blue" = "#2472c8";
        "terminal.ansi.bright_blue" = "#3b8eea";
        "terminal.ansi.dim_blue" = null;
        "terminal.ansi.magenta" = "#bc3fbc";
        "terminal.ansi.bright_magenta" = "#d670d6";
        "terminal.ansi.dim_magenta" = null;
        "terminal.ansi.cyan" = "#11a8cd";
        "terminal.ansi.bright_cyan" = "#29b8db";
        "terminal.ansi.dim_cyan" = null;
        "terminal.ansi.white" = "#e5e5e5";
        "terminal.ansi.bright_white" = "#e5e5e5";
        "terminal.ansi.dim_white" = null;
        "link_text.hover" = "#74ade8ff";
        "conflict" = "#dec184ff";
        "conflict.background" = "#dec1841a";
        "conflict.border" = "#5d4c2fff";
        "created" = "#a1c181ff";
        "created.background" = "#a1c1811a";
        "created.border" = "#38482fff";
        "deleted" = "#d07277ff";
        "deleted.background" = "#d072771a";
        "deleted.border" = "#4c2b2cff";
        "error" = "#d07277ff";
        "error.background" = "#d072771a";
        "error.border" = "#4c2b2cff";
        "hidden" = "#878a98ff";
        "hidden.background" = "#696b771a";
        "hidden.border" = "#414754ff";
        "hint" = "#970000ff";
        "hint.background" = "#5a6f891a";
        "hint.border" = "#293b5bff";
        "ignored" = "#878a98ff";
        "ignored.background" = "#696b771a";
        "ignored.border" = "#464b57ff";
        "info" = "#74ade8ff";
        "info.background" = "#74ade81a";
        "info.border" = "#293b5bff";
        "modified" = "#dec184ff";
        "modified.background" = "#dec1841a";
        "modified.border" = "#5d4c2fff";
        "predictive" = "#5a6a87ff";
        "predictive.background" = "#5a6a871a";
        "predictive.border" = "#38482fff";
        "renamed" = "#74ade8ff";
        "renamed.background" = "#74ade81a";
        "renamed.border" = "#293b5bff";
        "success" = "#a1c181ff";
        "success.background" = "#a1c1811a";
        "success.border" = "#38482fff";
        "unreachable" = "#a9afbcff";
        "unreachable.background" = "#8389941a";
        "unreachable.border" = "#464b57ff";
        "warning" = "#dec184ff";
        "warning.background" = "#dec1841a";
        "warning.border" = "#5d4c2fff";
        "players" = [
          {
            "cursor" = "#970000${opacity5}";
            "background" = "#${opacity13}";
            "selection" = "#${opacity6}";
          }
        ];
        "syntax" = {
          "attribute" = {
            "color" = "#994646";
            "font_style" = null;
            "font_weight" = null;
          };
          "boolean" = {
            "color" = "#994646";
            "font_style" = null;
            "font_weight" = null;
          };
          "comment" = {
            "color" = "#E7C0C0";
            "font_style" = "italic";
            "font_weight" = null;
          };
          "comment.doc" = {
            "color" = "#E7C0C0";
            "font_style" = "italic";
            "font_weight" = null;
          };
          "constant" = {
            "color" = "#994646";
            "font_style" = null;
            "font_weight" = null;
          };
          "constructor" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "embedded" = {
            "color" = "#F12727";
            "font_style" = null;
            "font_weight" = null;
          };
          "emphasis" = {
            "color" = "#f12727";
            "font_style" = "italic";
            "font_weight" = null;
          };
          "emphasis.strong" = {
            "color" = "#994646";
            "font_style" = null;
            "font_weight" = 700;
          };
          "enum" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "function" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "hint" = {
            "color" = "#5a6f89ff";
            "font_style" = null;
            "font_weight" = 700;
          };
          "keyword" = {
            "color" = "#F12727";
            "font_style" = null;
            "font_weight" = null;
          };
          "keyword.import" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "label" = {
            "color" = "#CD8D8D";
            "font_style" = null;
            "font_weight" = null;
          };
          "link_text" = {
            "color" = "#CD8D8D";
            "font_style" = "italic";
            "font_weight" = null;
          };
          "link_uri" = {
            "color" = "#f12727";
            "font_style" = null;
            "font_weight" = null;
          };
          "number" = {
            "color" = "#994646";
            "font_style" = null;
            "font_weight" = null;
          };
          "operator" = {
            "color" = "#F12727";
            "font_style" = null;
            "font_weight" = null;
          };
          "predictive" = {
            "color" = "#5a6a87ff";
            "font_style" = "italic";
            "font_weight" = null;
          };
          "preproc" = {
            "color" = "#c8ccd4ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "primary" = {
            "color" = "#acb2beff";
            "font_style" = null;
            "font_weight" = null;
          };
          "property" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation" = {
            "color" = "#acb2beff";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation.bracket" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation.delimiter" = {
            "color" = "#b2b9c6ff";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation.list_marker" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "punctuation.special" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "string" = {
            "color" = "#CD8D8D";
            "font_style" = null;
            "font_weight" = null;
          };
          "string.escape" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "string.regex" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "string.special" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "string.special.symbol" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "string.special.path" = {
            "color" = "#CD8D8D";
            "font_style" = null;
            "font_weight" = null;
          };
          "tag" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "text.literal" = {
            "color" = "#CD8D8D";
            "font_style" = null;
            "font_weight" = null;
          };
          "title" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = 400;
          };
          "type" = {
            "color" = "#e5c07b";
            "font_style" = null;
            "font_weight" = null;
          };
          "type.class" = {
            "color" = "#FEC758";
            "font_style" = null;
            "font_weight" = null;
          };
          "variable" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "variable.special" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "variable.parameter" = {
            "color" = "#FB9A4B";
            "font_style" = "italic";
            "font_weight" = null;
          };
          "variable.member" = {
            "color" = "#FFB454";
            "font_style" = null;
            "font_weight" = null;
          };
          "_expr" = {
            "color" = "#FB9A4B";
            "font_style" = "italic";
            "font_weight" = null;
          };
          "variant" = {
            "color" = "#CD8D8D";
            "font_style" = null;
            "font_weight" = null;
          };
        };
      };
    }
  ];
}
