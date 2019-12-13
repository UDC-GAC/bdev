# Copyright (c) 2019 Universidade da Coruña
# Authors:
#     - Jonatan Enes [main](jonatan.enes@udc.es, jonatan.enes.alvarez@gmail.com)
#     - Roberto R. Expósito
#     - Juan Touriño
#
# This file is part of the BDWatchdog framework, from
# now on referred to as BDWatchdog.
#
# BDWatchdog is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.
#
# BDWatchdog is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with BDWatchdog. If not, see <http://www.gnu.org/licenses/>.


def print_latex_section(section_name, section_label=None):
    if not section_label:
        section_label = section_name.replace(" ", "_")
    print("\\section{" + section_name + "}\label{" + section_label + "}")
    print("")


# def print_latex_vertical_space():
#     print("\\vspace{-0.3cm}")
#     print("")


def print_latex_stress(s):
    # Print the \newline string so that it is detected as a Latex newline
    # print(str + "\\newline")
    # print two additional spaces so that it is detected by markdown and pandoc as a newline
    print("\\textbf{" + s + "}" + "  ")
    print("")


def latex_print(s):
    # Print the \newline string so that it is detected as a Latex newline
    # print(str + "\\newline")
    # print two additional spaces so that it is detected by markdown and pandoc as a newline
    print(s + "  ")
    print("")
