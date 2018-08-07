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

  INCLUDES=`grep -R "^\#include" "$1" | sed 's/include//g' | sed 's/[#"<>]//g'`

  for INCLUDE in $INCLUDES; do
    filename "$INCLUDE"
    INCLUDE_FILENAME="$RETURN"
    #echo "Processing include: $INCLUDE_FILENAME ($INCLUDE)"

    for FILE in $FILES; do
      filename "$FILE"
      FILE_FILENAME="$RETURN"

      if [ "$FILE_FILENAME" = "$INCLUDE_FILENAME" ]; then
        #echo "Matched: $FILE_FILENAME ($FILE)"

        PROCESS_RETURN="$PROCESS_RETURN $FILE"

        process "$FILE"
      fi
    done
  done
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

  echo $RULE > "$1"

}

mainfunc "$1" "$2"
