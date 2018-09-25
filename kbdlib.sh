#!/bin/zsh
#        1         2         3         4         5         6         7         8         9
#234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
################################################################################
SCRIPT_NAME="Keyboard Lib"
################################################################################
KBDLIB_VERSION=0.001
AUTHOR="Orlando Hehl Rebelo dos Santos"
DATE_INI="17-01-2018"
DATE_END="17-01-2018"
################################################################################


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
   xchar=$(special_char_str "$readchar")

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
