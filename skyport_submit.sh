#!/bin/sh
# 
# skyport_submit script
#
# submit a CWL workflow, a jobinput file and a data directory for processing
# 
# simple AWE submitter

# PLEASE NOTE: all path info must be relative to DATADIR (in this case ./data)

# usage info
function usage () {
        echo "Usage: skyport2.sh -d ~/data -j jobinput.yaml  -w workflow-simple.yaml [-s SKYPORT_HOST]"
	echo "if not -S <var> is provided, SKYPORT_HOST environment variable is used, if neither is present default is localhost"
 }

 # get options
while getopts d:w:j:s:a: option; do
    case "${option}"
        in
                w) WORKFLOW=${OPTARG};;
                j) JOBINPUT=${OPTARG};;
                d) DATADIR=${OPTARG};;
                s) SKYPORT_HOST=${OPTARG};; 
                *)
                usage
                ;;
    esac
done

# check on the auth situation
if [ -z ${SKYPORT_AUTH} ]
then
        echo "We did not find an auth token (-a or $SKYPORT_AUTH). Running in anonymous mode"
fi

# make sure the required options are present
if [[ -z ${WORKFLOW} ]]
then
        usage
        exit 1
fi
# make sure the required options are present
if [[ -z ${JOBINPUT} ]]
then
        usage
        exit 1
fi
# make sure the required options are present
if [[ -z ${DATADIR} ]]
then
        usage
        exit 1
fi

# we either used the ENVIRONMENT variable or the cmd-line parameter here with the standard unix order of precedence
if [[ -z ${SKYPORT_HOST} ]]
then   
	if [ ${OS} == "Darwin" ]
	then
	  MYIP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
	else
	  MYIP=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
	fi
	# set to external host IP
	SKYPORT_HOST=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)	
fi

WORKFLOWDIR=dirname ${WORKFLOW}
JOBINPUTDIR=dirname ${JOBINPUT} 

WORKFLOW-FILE=basename ${WORKFLOW}
JOBINPUT-FILE=basename ${JOBINPUT}

if [ ! -d ${DATADIR} ]
then
 echo "directory $DATADIR does not exist!"
 exit 1
fi



AWE_SERVER=http://${SKYPORT_HOST}:8001/awe/api/
SHOCK_SERVER=http://${SKYPORT_HOST}:8001/shock/api/

# check if we have an AUTH token
if [ -z ${SKYPORT_AUTH} ]
then
	docker run -ti \
	  --network compose_default \
	  --rm \
	  -v `pwd`/${WORKFLOWDIR}:/mnt/workflows/ \
	  -v `pwd`/${JOBINPUTDIR}:/mnt/jobinputs/ \
	  -v `pwd`/${DATADIR}:/mnt/data/ \
	  --workdir=`pwd`/${DATADIR} \
	  mgrast/awe-submitter:develop \
	  /go/bin/awe-submitter \
	  --pack \
	  --shockurl=${SHOCK_SERVER} \
	  --serverurl=${AWE_SERVER} \
	  /mnt/workflows/${WORKFLOW-FILE} \
	  /mnt/jobinputs/${JOBINPUT-FILE}

else
# run with auth param
docker run -ti \
          --network compose_default \
          --rm \
          -v `pwd`/${WORKFLOWDIR}:/mnt/workflows/ \
          -v `pwd`/${JOBINPUTDIR}:/mnt/jobinputs/ \
          -v `pwd`/${DATADIR}:/mnt/data/ \
          --workdir=`pwd`/${DATADIR} \
          mgrast/awe-submitter:develop \
          /go/bin/awe-submitter \
          --pack \
          --shockurl=${SHOCK_SERVER} \
          --serverurl=${AWE_SERVER} \
          --auth=${SKYPORT_AUTH} \
          /mnt/workflows/${WORKFLOW-FILE} \
          /mnt/jobinputs/${JOBINPUT-FILE}

fi


