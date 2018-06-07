#!/bin/ksh
#        1         2         3         4         5         6         7         8         9
#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
################################################################################
SH_SCRIPT_NAME="PLSNCSH Calc"
################################################################################
VERSION=0.90
AUTHOR="Orlando Hehl Rebelo dos Santos"
DATE_INI="05-08-2017"
DATE_END="21-08-2017"
################################################################################

clear

function print_regs {
   printf  "\r                    \n"

   if [[ -n ${regs[0]} ]]; then

       regs_length=0
       #This loop is used to count the vector elements not null as
       #unused elements are not freed up in memory, by the shell 
       for index in "${!regs[@]}"; do
           if [[ -n ${regs[index]} ]]; then
              ((regs_length++))
           fi
       done

       columns_available=$((COLUMNS - 3))
       for index in "${!regs[@]}"; do
           if [[ -n ${regs[index]} ]]; then
                  printf "%2d:%${columns_available}.${PRECISION}f\n" $regs_length ${regs[$index]}
               ((regs_length--))
           fi
       done
    else
          echo "(EMPTY STACK)"
    fi

   for ((i=0; i < COLUMNS; i++)); do
      #printf " "
      printf "-"
   done
   printf "\n>"
}

function set_precision {
   #typeset -i PRECISION

   if [[ -n ${1} ]]; then
      PRECISION=${1}
      input=""
   else
      PRECISION=${regs[reg_idx - 1]}
      drop_regs
   fi

   #Unlike trunc(), abs() must be used because of printf() formating option.
   PRECISION=$((abs(PRECISION)))
}

set_precision 2
reg_idx=0
typeset -F10 input_f

usage(){
        print $SH_SCRIPT_NAME
	print "Usage: plncalc.ksh [-p precision] [-v] "
	print "  -k   Precision"
	print "  -v   Print version and exit"
	print "  -h   Print help and exit"
}

while getopts "k:vh" arg
do
        case $arg in
            k)
                set_precision $OPTARG
                ;;
            v)
                print "${SH_SCRIPT_NAME} ${VERSION}"
                exit 0
                ;;
            h|*)
                usage
                exit 1
                ;;
        esac
done

shift $(($OPTIND - 1))

#if [ $# -lt 1 ]; then
        #usage
        #print ERROR: no files specified
        #exit 1
#fi


print "${SH_SCRIPT_NAME} ${VERSION}"

function clear {
   printf  "\r                               \r"
   input=""
}

# this function returns a string identifying the keystroke as a
# special character.
special_char_str () {

if [[ -z "$1" ]]
then # undefined argument
   echo "UNDEF"
elif [[ -z $(echo "$1"|tr -d '\001') ]]
then # control_a
   echo "CTRL_A"
elif [[ -z $(echo "$1"|tr -d '\002') ]]
then # control_b
   echo "CTRL_B"
elif [[ -z $(echo "$1"|tr -d '\003') ]]
then # control_c
   echo "CTRL_C"
elif [[ -z $(echo "$1"|tr -d '\004') ]]
then # control_d
   echo "CTRL_D"
elif [[ -z $(echo "$1"|tr -d '\005') ]]
then # control_e
   echo "CTRL_E"
elif [[ -z $(echo "$1"|tr -d '\006') ]]
then # control_f
   echo "CTRL_F"
elif [[ -z $(echo "$1"|tr -d '\007') ]]
then # control_g
   echo "CTRL_G"
elif [[ -z $(echo "$1"|tr -d '\010') ]]
then # BS key or control_h
   echo "BS"
elif [[ -z $(echo "$1"|tr -d '\011') ]]
then # TAB key or control-i
   echo "TAB"
elif [[ -z $(echo "$1"|tr -d '\012') ]]
then # NL \n or control_j
   echo "NL"
elif [[ -z $(echo "$1"|tr -d '\013') ]]
then # control_k
   echo "CTRL_K"
elif [[ -z $(echo "$1"|tr -d '\015') ]]
then # CR \r or control_m
   echo "CR"
elif [[ -z $(echo "$1"|tr -d '\020') ]]
then # control_p
   echo "CTRL_P"
elif [[ -z $(echo "$1"|tr -d '\033') ]]
then # ESC
   echo "ESC"
elif [[ -z $(echo "$1"|tr -d '\177') ]]
then # DEL key 
   echo "DEL"
else
   echo $1
fi
}

# NewGetKey - this function demonstrates using cursor keys in ksh 
# scripts. Return a string identifying the key stroke as a special character
# or just return the key.
# Original by Heiner Steven (heiner.steven@odn.de)
# modified by Ed Schaefer and John Spurgeon to add function keys
# and control characters.

NewGetKey () {
   typeset readchar
   typeset xchar
   typeset second
   typeset xsecond
   typeset third
   typeset oldstty="$(stty -g)"

   stty -icanon -echo  -icrnl min 1 time 0 -isig  #icrnl (-icrnl) Map (do not map) CR to NL on input.
   readchar=$(dd bs=1 count=1 2>/dev/null)
#print "readchar:$readchar"
   xchar=$(special_char_str "$readchar")
#print "xchar:$xchar"

   case "$xchar" in
        UNDEF) readchar=UNDEF;;
        CR) readchar=CR;;
        NL) readchar=NL;;
        CTRL_A|CTRL_B|CTRL_C|CTRL_D|CTRL_E|CTRL_F|CTRL_G|CTRL_K|CTRL_L|CTRL_N|CTRL_P|BS|TAB|DEL) readchar=$xchar;;
        ESC) # ecape sequence.  Read second char.
            second=$(dd bs=1 count=1 2>/dev/null)
            xsecond=$(special_char_str $second)
            case "$xsecond" in
                '[')
                    third=$(dd bs=1 count=1 2>/dev/null)
                    case "$third" in
                        'A')    readchar=CURS_UP;;
                        'B')    readchar=CURS_DOWN;;
                        'C')    readchar=CURS_RIGHT;;
                        'D')    readchar=CURS_LEFT;;
                        '1')    
                                fourth=$(dd bs=1 count=1 2>/dev/null)
                                fifith=$(dd bs=1 count=1 2>/dev/null)
                                case "$fourth" in
                                    '5')    readchar=FN_05;;
                                    '7')    readchar=FN_06;;
                                    '8')    readchar=FN_07;;
                                    '9')    readchar=FN_08;;
                                     *)     readchar="$readchar$second$third$fourth";;
                                esac;;
                        '2')    
                                fourth=$(dd bs=1 count=1 2>/dev/null)
                                fifith=$(dd bs=1 count=1 2>/dev/null)
                                case "$fourth" in
                                    '0')    readchar=FN_09;;
                                    '1')    readchar=FN_10;;
                                    '4')    readchar=FN_12;;
                                     *)     readchar="$readchar$second$third$fourth";;
                                esac;;

                          *)    readchar="$readchar$second$third";;
                    esac;;
                'O')  # O for function keys
                    third=`dd bs=1 count=1 2>/dev/null`
                    case "$third" in
                        'P')    readchar=FN_01;;
                        'Q')    readchar=FN_02;;
                        'R')    readchar=FN_03;;
                        'S')    readchar=FN_04;;
                        *)      readchar="$readchar$second$third";;
                    esac;;

                *)              # No escape sequence
                    readchar="$readchar$second";print "NO_ESCAPE";;
            esac ;;
   esac
   stty $oldstty # restore original terminal settings
   echo "$readchar"
}
set -A regs


function drop_regs {
   if(( $reg_idx > 0)); then
      regs[reg_idx - 1]=""
      ((reg_idx--))
      print_regs
   fi
}

function load_reg {
   print -n ${1}
   input="${input}${1}"
   input_f=$input
}


function enter {

   if [[ -n $input ]]; then
      regs[$reg_idx]=$input_f
      input=""
   else
      regs[$reg_idx]=${regs[reg_idx - 1]}
   fi
   ((reg_idx++))

   printf  "\r                               "
   print_regs
}

function add {
   if(( $reg_idx < 1)); then return;fi
   #if(( $reg_idx < 1)); then print "Error!"; return;fi

   if [[ -n $input ]]; then
      regs[reg_idx - 1]=$((input_f + regs[reg_idx - 1]))
      regs[reg_idx]=""
      input=""
   else
      regs[reg_idx - 2]=$((regs[reg_idx - 2] + regs[reg_idx - 1]))
      ((reg_idx--))
      regs[reg_idx]=""
      #regs[reg_idx - 1]=""
   fi

   print_regs
}

function sub {
   if(( $reg_idx < 1)); then print "Error!"; return;fi

   if [[ -n $input ]]; then
      regs[reg_idx - 1]=$((regs[reg_idx - 1] - input_f))
      regs[reg_idx]=""
      input=""
   else
      regs[reg_idx - 2]=$((regs[reg_idx - 2] - regs[reg_idx - 1]))
      ((reg_idx--))
      regs[reg_idx]=""
      #regs[reg_idx - 1]=""
   fi

   print_regs
}

function mul {
   if(( $reg_idx < 1)); then print "Error!"; return;fi

   if [[ -n $input ]]; then
      regs[reg_idx - 1]=$((regs[reg_idx - 1] * input_f))
      regs[reg_idx]=""
      input=""
   else
      regs[reg_idx - 2]=$((regs[reg_idx - 2] * regs[reg_idx - 1]))
      ((reg_idx--))
      regs[reg_idx]=""
   fi

   print_regs
}

function div {
   if(( $reg_idx < 1)); then print "Error!"; return;fi

   if [[ -n $input ]]; then
      regs[reg_idx - 1]=$((regs[reg_idx - 1] / input_f))
      regs[reg_idx]=""
      input=""
   else
      regs[reg_idx - 2]=$((regs[reg_idx - 2] * 1.0 / regs[reg_idx - 1]))
      ((reg_idx--))
      regs[reg_idx]=""
   fi

   print_regs
}

function swap {
   aux=${regs[reg_idx - 2]}
   regs[reg_idx - 2]=${regs[reg_idx - 1]}
   regs[reg_idx - 1]=$aux

   print_regs
}

function sqrt {
   if [[ -n $input ]]; then
      regs[$reg_idx]=$((sqrt(input_f)))
      input=""
      ((reg_idx++))
   else
      regs[reg_idx - 1]=$((sqrt(${regs[reg_idx - 1]})))
      regs[reg_idx]=""
   fi

   print_regs
}

function abs {
   if [[ -n $input ]]; then
      regs[$reg_idx]=$((abs(input_f)))
      input=""
      ((reg_idx++))
   else
      regs[reg_idx - 1]=$((abs(${regs[reg_idx - 1]})))
      regs[reg_idx]=""
   fi

   print_regs
}

function minus {
   if [[ -n $input ]]; then
      input_f=$((input_f * (-1)))
      printf "\r%.${PRECISION}f                        " $input_f
   else
      regs[reg_idx - 1]=$((${regs[reg_idx - 1]} * (-1)))
      regs[reg_idx]=""
      print_regs
   fi
}

function round {
   if [[ -n $input ]]; then
      input_f=$((round(input_f)))
      printf "\r%.${PRECISION}f                        " $input_f
   else
      regs[reg_idx - 1]=$((round(${regs[reg_idx - 1]})))
      regs[reg_idx]=""
      print_regs
   fi
}

function trunc {
   if [[ -n $input ]]; then
      input_f=$((trunc(input_f)))
      printf "\r%.${PRECISION}f                        " $input_f
   else
      regs[reg_idx - 1]=$((trunc(${regs[reg_idx - 1]})))
      regs[reg_idx]=""
      print_regs
   fi
}

function float_p_reminder {
   if [[ -n $input ]]; then
      input_f=$((fmod(input_f)))
      printf "\r%.${PRECISION}f                        " $input_f
   else
      regs[reg_idx - 1]=$((fmod(${regs[reg_idx - 1]})))
      regs[reg_idx]=""
      print_regs
   fi
}
 
function double_zeros {
   load_reg "00"
}

function triple_zeros {
   load_reg "000"
}

function print_command_list {
   clear
   printf  "**********************************************\n"
   printf  "Available Commands:\n\n"
   printf  "m=+/-   r=sqrt   a=abs   k=precision   T=trunc\n"
   printf  "**********************************************\n\n"
   printf  "Press any key to continue...                  \n\n"
   read -n1
   print_regs
}

while true; do
    Key=$(NewGetKey)
    case "$Key" in
           #CTRL_A)      print -n "CTRL_A";;
           CTRL_B)      print -n "CTRL_B";;
           CTRL_C)      printf "\nbye!\n"; exit 0;;
           CTRL_P)      print_regs;;
               #BS)      print -n "BS";;
              #TAB)      print -n "TAB";;
            #UNDEF)      print -n "UNDEF";;
               CR)      enter;;
               #NL)      print -n "NL";;
          #CURS_UP)      print -n "UP_ARROW";;
        #CURS_DOWN)      print -n "DOWN_ARROW";;
       #CURS_RIGHT)      print -n "RIGHT_ARROW";;
        #CURS_LEFT)      print -n "LEFT_ARROW";;
            #FN_01)      print -n "F1";;
            FN_05)       swap;;
            FN_06)       round;;
            FN_07)       print_command_list;;
            #FN_09)       double_zeros;;
            FN_10)       triple_zeros;;
            #FN_11)      print -n "F11";;
            #FN_12)      print -n "F12";;
              DEL)      clear;;
                *)      case $Key in
                            '~') round;;
                            ',') double_zeros;;
                            '+') add;;
                            '-') sub;;
                            '*') mul;;
                            '/') div;;
                            'T') trunc;;
                            'a') abs;;
                            'd') drop_regs;;
                            'f') float_p_reminder;;
                            'k') set_precision $input
                                 print_regs
                                 ;;
                            'm') minus;;
                            'p') load_reg "3.1415926535";;
                            'r') sqrt;;
                             [0-9.])load_reg "$Key";;
                        esac
    esac
done
