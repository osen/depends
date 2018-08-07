FILES=`find . -name '*.c' -o -name '*.h'`
RETURN=

function filename()
{
  RETURN=`basename "$1"`
}

function process()
{
  #echo "Processing: $2"

  CURR=

  INCLUDES=`grep -R "^\#include" "$2" | sed 's/include//g' | sed 's/[#"<>]//g'`

  #if [ -z "$INCLUDES" ]; then
  #  return
  #fi

  for INCLUDE in $INCLUDES; do
    filename "$INCLUDE"
    INCLUDE_FILENAME="$RETURN"
    #echo "Processing include: $INCLUDE_FILENAME ($INCLUDE)"

    for FILE in $1; do
      filename "$FILE"
      FILE_FILENAME="$RETURN"
      #echo "FILE FILENAME: $FILE_FILENAME"

      if [ "$FILE_FILENAME" = "$INCLUDE_FILENAME" ]; then
        #echo "Matched: $FILE_FILENAME ($FILE)"

        PROCESS_RETURN=`process "$1" "$FILE"`
        CURR="$CURR $FILE $PROCESS_RETURN"
      fi
    done
  done

  echo $CURR
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

  PROCESS_RETURN=`process "$FILES" "$2"`

  findobj "$2"
  OBJ=$RETURN
  RULE="$OBJ:$PROCESS_RETURN"

  substituterule "$1" "$OBJ" "$RULE"

}

mainfunc "$1" "$2"
