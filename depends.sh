FILES=`find . -name '*.c' -o -name '*.h'`
RETURN=
KNOWNLIST=
OPENLIST=

function listadd()
{
  LIST=

  if [ "$1" = "OPENLIST" ]; then
    LIST="$OPENLIST"
  else
    LIST="$KNOWNLIST"
  fi

  for ITEM in $LIST; do
    if [ "$ITEM" = "$2" ]; then
      echo "Error: List already contains item"
      exit 1
    fi
  done

  LIST="$LIST $2"

  if [ "$1" = "OPENLIST" ]; then
    OPENLIST="$LIST"
  else
    KNOWNLIST="$LIST"
  fi
}

function listpop()
{
  LIST=

  if [ "$1" = "OPENLIST" ]; then
    LIST="$OPENLIST"
  else
    LIST="$KNOWNLIST"
  fi

  FIRST=1
  RETURN=
  RETURN_LIST=

  for ITEM in $LIST; do
    if [ $FIRST = 1 ]; then
      RETURN="$ITEM"
      FIRST=0
    else
      RETURN_LIST="$RETURN_LIST $2"
    fi
  done

  if [ "$1" = "OPENLIST" ]; then
    OPENLIST="$RETURN_LIST"
  else
    KNOWNLIST="$RETURN_LIST"
  fi
}

function listcontains()
{
  LIST=

  if [ "$1" = "OPENLIST" ]; then
    LIST="$OPENLIST"
  else
    LIST="$KNOWNLIST"
  fi

  for ITEM in $LIST; do
    if [ "$ITEM" = "$2" ]; then
      RETURN=1
      return
    fi
  done

  RETURN=0
}

function filename()
{
  RETURN=`basename "$1"`
}

function process()
{
  while true; do

    listpop "OPENLIST"
    ITEM="$RETURN"

    if [ -z "$ITEM" ]; then
      break
    fi

    #echo "Processing: $ITEM"

    INCLUDES=`grep -R "\#include" "$ITEM" | sed 's/include//g' | sed 's/[#"<>]//g'`

    if [ -z "$INCLUDES" ]; then
      continue
    fi

    for INCLUDE in $INCLUDES; do
      filename "$INCLUDE"
      INCLUDE_FILENAME="$RETURN"
      #echo "Processing include: $INCLUDE_FILENAME ($INCLUDE)"

      for FILE in $FILES; do
        filename "$FILE"
        FILE_FILENAME="$RETURN"

        if [ "$FILE_FILENAME" = "$INCLUDE_FILENAME" ]; then
          #echo "Matched: $FILE_FILENAME ($FILE)"

          listcontains "KNOWNLIST" "$FILE"

          if [ $RETURN = 0 ]; then
            listadd "OPENLIST" "$FILE"
            listadd "KNOWNLIST" "$FILE"
            PROCESS_RETURN="$PROCESS_RETURN $FILE"
          fi
        fi
      done
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

  listadd "KNOWNLIST" "$2"
  listadd "OPENLIST" "$2"

  process

  findobj "$2"
  OBJ=$RETURN
  RULE="$OBJ:$PROCESS_RETURN"

  substituterule "$1" "$OBJ" "$RULE"
}

mainfunc "$1" "$2"
