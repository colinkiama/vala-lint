 /*
 * Copyright (c) 2016-2019 elementary LLC. (https://github.com/elementary/vala-lint)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Marcus Wichelmann <marcus.wichelmann@hotmail.de>
 */

public class ValaLint.Checks.BlockOpeningBraceSpaceBeforeCheck : Check {
    public BlockOpeningBraceSpaceBeforeCheck () {
        Object (
            title: "block-opening-brace-space-before",
            description: _("Checks for correct use of opening braces"),
            single_mistake_in_line: true
        );

        state = Config.get_state (title);
    }

    public override void check (Vala.ArrayList<ParseResult?> parse_result,
                                ref Vala.ArrayList<FormatMistake?> mistake_list) {
        foreach (ParseResult r in parse_result) {
            if (r.type == ParseType.DEFAULT) {
                add_regex_mistake ("""[\w)=]\n\s*{""", _("Unexpected line break before \"{\""), r,
                                   ref mistake_list, 1, 1);
                add_regex_mistake ("""[\w)=]{""", _("Expected whitespace before \"{\""), r,
                                   ref mistake_list, 1, 1);
            }
        }
    }

    public override bool apply_fix (Vala.SourceLocation begin, Vala.SourceLocation end, ref string contents) {
        var lines = contents.split ("\n");

        var line = lines[begin.line - 1];


        // Expected whitespace before
        if (line[begin.column] == '{') {
            lines[begin.line - 1] = line[0:begin.column] + " " + line[begin.column:line.length];
        } else {
            // Unexpected linebreak before
            line = line[0:begin.column] + " " + "{";
            lines[begin.line - 1] = line;

            var next_line = lines[begin.line];
            int spaces_to_indent = next_line.index_of ("{", 0);
            var next_line_stripped = next_line[spaces_to_indent + 1:next_line.length].strip ();

            // Either just remove opening bracket or move sole closing bracket to
            // previous opening bracket position
            if (next_line_stripped == "}") {
                var sb = new StringBuilder ();
                for (int i = 0; i < spaces_to_indent; i++) {
                    sb.append (" ");
                }

                lines[begin.line] = sb.str + "}";
            } else {
                lines[begin.line] = next_line[0:spaces_to_indent] + next_line[spaces_to_indent + 1:next_line.length];
            }
        }

        contents = string.joinv ("\n", lines);
        return true;
    }
}
