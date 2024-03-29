# html-to-pdf() {
#   weasyprint --stylesheet ~/.config/markdown/screen.css - -
# }

# md-to-html() {
#   pandoc --from=markdown --to=html
# }

# md-to-pdf() {
#   md-to-html | html-to-pdf
# }

# md-to-pdf-file() {
#   input="/dev/stdin"
#   output=$(mktemp /tmp/file-XXX.pdf)
#   case $# in
#   0) ;;
#   1)
#     case "$1" in
#     *.md)
#       input="$1"
#       ;;
#     *.pdf)
#       output="$1"
#       ;;
#     *)
#       echo "Expecting either a markdown file ending in .md or a PDF file ending in .pdf when run with one argument" 1>&2
#       return 10
#       ;;
#     esac
#     ;;
#   2)
#     input="$1"
#     output="$2"
#     ;;
#   *)
#     cat <<EOF
# Converts markdown text into a PDF file.
#
# Input and output are determined based on number of command line arguments provided.
#
# With no arguments, markdown will be read from standard input and a PDF file will be generated in /tmp/file-XXX.pdf with a unique temporary filename. The temporary filename will be written to standard output.
#
# With one argument, the file name will be matched based on .md or .pdf extension and treated as input or output accordingly. The input will come from standard input if a .pdf argument is provided, otherwise the .md argument will be processe as input to a temporary output PDF file.
#
# In all cases, the name of the output .pdf file will be written to standard output.
# EOF
#     return 10
#     ;;
#   esac
#   md-to-html <"${input}" | html-to-pdf >"${output}"
#   echo "${output}"
# }
