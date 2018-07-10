
# This is the Litmus test part

# TODO



# This is the multiple outputs part
# For a given program, see how many different outputs we may get

pushd multiOutput > /dev/null

for SOLVER in lingeling; do

    echo " ==> Finding all outputs that can be achieved for each litmus test -- ${SOLVER} -- SC"
    time conjure solve ../../mcm-multiOutput.essence ../../litmus/*-SC.param  \
        -o conjure-output \
        --number-of-solutions=all \
        --copy-solutions=no \
        --solver=${SOLVER}

    echo " ==> Finding all outputs that can be achieved for each litmus test -- ${SOLVER} -- TSO"
    time conjure solve ../../mcm-multiOutput.essence ../../litmus/*-TSO.param  \
        -o conjure-output \
        --number-of-solutions=all \
        --copy-solutions=no \
        --solver=${SOLVER}

    parallel -j1 --tag 'ls conjure-output/*-{.}*.solution | tail -n1' ::: $(cd ../../litmus ; ls *.param)

done

popd > /dev/null



# This is listing all TSO programs, and filtering the SC ones

pushd TSO-notSC > /dev/null

for SOLVER in lingeling minion; do
    for CASE in A B; do

        echo " ==> Listing TSO programs -- ${SOLVER} - ${CASE}"

        rm -f conjure-output/*solution
        time conjure solve ../../mcm.essence ${CASE}-TSO-list.param \
            -o conjure-output \
            --copy-solutions=no \
            --solver=${SOLVER} \
            --line-width=100000 \
            --number-of-solutions=all

        echo " ==> Creating SC include list -- ${SOLVER} - ${CASE}"

        (cd conjure-output ; grep 'letting program' *.solution | cut -d ' ' -f 4- > ../${CASE}-allTSO.list)
        LC_ALL=C sort ${CASE}-allTSO.list -o ${CASE}-allTSO.list

        cp ${CASE}-SC-list.param-part ${CASE}-SC-list.param
        python3 mkSCList.py ${CASE}-allTSO.list >> ${CASE}-SC-list.param

        echo " ==> Listing SC programs -- ${SOLVER} - ${CASE}"

        rm -f conjure-output/*solution
        time conjure solve ../../mcm.essence ${CASE}-SC-list.param \
            -o conjure-output \
            --copy-solutions=no \
            --solver=${SOLVER} \
            --line-width=100000 \
            --number-of-solutions=all

        (cd conjure-output ; grep 'letting program' *.solution | cut -d ' ' -f 4- > ../${CASE}-allSC.list)
        LC_ALL=C sort ${CASE}-allSC.list -o ${CASE}-allSC.list

        mkdir -p results
        mv ${CASE}-allTSO.list ${CASE}-allSC.list results
        python3 TSOminusSC.py results/${CASE}-allTSO.list results/${CASE}-allSC.list results/${CASE}-onlyTSO.list
        LC_ALL=C sort results/${CASE}-onlyTSO.list -o results/${CASE}-onlyTSO.list
        wc -l results/${CASE}-*.list | grep -v total

        rm -f ${CASE}-SC-list.param conjure-output/model000001-*

    done
done

popd > /dev/null


