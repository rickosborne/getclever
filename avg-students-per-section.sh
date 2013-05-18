#!/bin/bash

DATA_FILE='sections.json'
DATA_URL='https://api.getclever.com/v1.1/sections'
CERT_FILE='ca-certificates.crt'
CERT_URL='https://raw.github.com/Clever/clever-php/master/lib/data/ca-certificates.crt'
API_KEY='DEMO_KEY'
VERBOSE=""

while (( "$#" )) ; do
    if [ "$1" == "-v" ] ; then
        VERBOSE=1
        shift
    fi
done

function whisper {
    if [ ! -z "${VERBOSE}" ] ; then
        echo "$1"
    fi
}

function scrub {
    SCRUB_FILE=$1
    if [ -f "${SCRUB_FILE}" ] ; then
        rm "${SCRUB_FILE}"
    fi
}

function fetch {
    FETCH_FILE=$1
    FETCH_URL=$2
    if [ -f "${FETCH_FILE}" ] ; then
        whisper "Found existing ${FETCH_FILE}."
    else
        CURL_PATH=`which curl`
        if [ -z "${CURL_PATH}" ] ; then
            WGET_PATH=`which wget`
            if [ -z "${WGET_PATH}" ] ; then
                echo "ERROR: You have neither curl nor wget installed.  Really?"
                exit 1
            else
                whisper "Using ${WGET_PATH} to fetch ${FETCH_URL} into ${FETCH_FILE}."
                # ouch, encapsulation
                if [ -f "${CERT_FILE}" ] ; then
                    CERT_OPT=--ca-certificate="${CERT_FILE}"
                else
                    CERT_OPT=--no-check-certificate
                fi
                eval $WGET_PATH -q --http-user="${API_KEY}" --http-password="" -O "${FETCH_FILE}" $CERT_OPT "${FETCH_URL}"
            fi
        else
            whisper "Using ${CURL_PATH} to fetch ${FETCH_URL} into ${FETCH_FILE}."
            if [ -f "${CERT_FILE}" ] ; then
                CERT_OPT='--cacert "${CERT_FILE}"'
            else
                CERT_OPT=--insecure
            fi
            eval $CURL_PATH $CERT_OPT -s -o "${FETCH_FILE}" -u "${API_KEY}:" "${FETCH_URL}"
        fi
    fi
}

fetch "${CERT_FILE}" "${CERT_URL}"
fetch "${DATA_FILE}" "${DATA_URL}"

# Strip the data down to lists of students

TEMP_FILE='section-students.txt'
grep -o '"students":\[[^]]*' "${DATA_FILE}" > "${TEMP_FILE}"

# Yeah, we could have done this with the API using count=true,
# but let's assume API calls are more expensive than text processing.
# We need to use tr to remove non-numbers, as wc is verbose.

SECTION_COUNT=`wc -l "${TEMP_FILE}" | tr -dc '[:digit:]'`
echo "Sections: ${SECTION_COUNT}"

# Okay, this is sortof cheating as we're counting delimiters.

STUDENT_COUNT=`cat "${TEMP_FILE}" | tr -dc ',:' | wc -c | tr -dc '[:digit:]'`
echo "Students: ${STUDENT_COUNT}"

STUDENTS_PER_SECTION=`echo "scale=2;${STUDENT_COUNT}.0 / ${SECTION_COUNT}.0" | bc`
echo "Students per Section: ${STUDENTS_PER_SECTION}"

scrub "${TEMP_FILE}"
scrub "${DATA_FILE}"
scrub "${CERT_FILE}"
