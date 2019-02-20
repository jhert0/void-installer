#!/bin/bash

yes_no_prompt(){
    read -p "$1 [y/N] "
}

contains_element(){
    for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
}
