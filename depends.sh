FILES=`find . -name '*.c' -o -name '*.h'`
RETURN=
KNOWNLIST=
OPENLIST=

##############################################################################
# listadd
#
# Params:
#   - The list to add to
#   - The item to add to the list
#
# Add the specified item to the specified list. Works in a similar way to the
# C++ std::vector<T>::add.
#
##############################################################################
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

##############################################################################
# listpop
#
# Params:
#   - The list to pop from
#
# Returns:
#   The first item from the list that has been removed
#
# Remove the first element from the specified list and return it. It works
# like a queue (FIFO).
#
##############################################################################
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

##############################################################################
# listcontains
#
# Params:
#   - The list to search in
#   - The item to search for
#
# Returns:
#   Either 1 or 0 depending on if the specified item was found
#
# Search within the specified list for the specified item and return the
# result.
#
##############################################################################
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

##############################################################################
# filename
#
# Params:
#   - The full path to a file
#
# Returns:
#   The filename of the specified file
#
# Obtain a specified file's filename. It works by cropping the last part after
# the last '/'. Uses the "basename" function underneath.
#
##############################################################################
function filename()
{
  RETURN=`basename "$1" 2>/dev/null`
}

##############################################################################
# process
#
# Returns:
#   A list of files that was referenced by the file in the open list.
#
# While there are files in the open list, read them and if they have not
# already been processed, add them to the open list for future processing.
# Add each file that has needed processing to the return result.
#
##############################################################################
function process()
{
  RTN=

  while true; do

    listpop "OPENLIST"
    ITEM="$RETURN"

    if [ -z "$ITEM" ]; then
      break
    fi

    #echo "Processing: $ITEM"

    INCLUDES=`grep -R "\#include" "$ITEM" | sed 's/include//g' | sed 's/[ #"<>]//g'`

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
            RTN="$RTN $FILE"
          fi
        fi
      done
    done
  done

  RETURN="$RTN"
}

##############################################################################
# findobj
#
# Params:
#   - The path of the source unit
#
# Returns:
#   The path of the corresponding object
#
# Based on the specified path, return the path of the corresponding object.
#
##############################################################################
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

##############################################################################
# substituterule
#
# Params:
#   - The path of the dependency Makefile
#   - The name of the object the rule is for
#   - The rule string
#
# Add the specified rule to the dependency Makefile. If a rule already
# exists for the specified object, then replace it.
#
##############################################################################
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

##############################################################################
# mainfunc
#
# Params:
#   - The path of the dependency Makefile
#   - The path of the source unit to scan
#
# Scan the specified unit for all dependent includes recursively and add to
# the dependencies Makefile (or update it if rule already exists).
#
##############################################################################
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
  RULE="$RETURN"

  findobj "$2"
  OBJ=$RETURN
  RULE="$OBJ:$RULE"

  substituterule "$1" "$OBJ" "$RULE"
}

mainfunc "$1" "$2"
