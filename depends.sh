FILES=`find . -name '*.c' -o -name '*.h'`
RETURN=
PROCESS_RETURN=

function filename()
{
  RETURN=`basename "$1"`
}

function process()
{
  #echo "Processing: $1"

  local CURR=

  local INCLUDES=`grep -R "^\#include" "$1" | sed 's/include//g' | sed 's/[#"<>]//g'`

  #if [ -z "$INCLUDES" ]; then
  #  return
  #fi

  for INCLUDE in $INCLUDES; do
    filename "$INCLUDE"
    local INCLUDE_FILENAME="$RETURN"
    #echo "Processing include: $INCLUDE_FILENAME ($INCLUDE)"

    for FILE in $FILES; do
      filename "$FILE"
      local FILE_FILENAME="$RETURN"
      #echo "FILE FILENAME: $FILE_FILENAME"

      if [ "$FILE_FILENAME" = "$INCLUDE_FILENAME" ]; then
        #echo "Matched: $FILE_FILENAME ($FILE)"

        PROCESS_RETURN="$PROCESS_RETURN $FILE"
        CURR="$CURR $FILE"

        process "$FILE"
      fi
    done
  done

  #echo $CURR
}

function findobj()
{
  OBJ1=`echo "$1" | sed 's/\..*$//'`.obj

  if [ -f "$OBJ1" ]; then
    RETURN=$OBJ1
  else
    OBJ2=`echo "$1" | sed 's/\..*$//'`.o
    RETURN=$OBJ2
  fi
}

function substituterule()
{
  if [ ! -f "$1" ]; then
    echo $RULE > "$1"
    return
  fi

  OUT=depends.Mk.tmp
  touch "$OUT"
  FOUND=0

  while read -r LINE; do
    OBJ=`echo "$LINE" | sed 's/:.*$//'`

    if [ "$OBJ" = "$2" ]; then
      echo "$3" >> "$OUT"
      FOUND=1
    else
      echo "$LINE" >> "$OUT"
    fi
  done < "$1"

  if [ $FOUND = 0 ]; then
    echo "$3" >> "$OUT"
  fi

  mv "$OUT" "$1"
}

function mainfunc()
{
  if [ -z "$1" ]; then
    echo "Error: No output specified"
    exit 1
  fi

  if [ -z "$2" ]; then
    echo "Error: No input specified"
    exit 1
  fi

  process "$2"

  findobj "$2"
  OBJ=$RETURN
  RULE="$OBJ:$PROCESS_RETURN"

  substituterule "$1" "$OBJ" "$RULE"

}

mainfunc "$1" "$2"
