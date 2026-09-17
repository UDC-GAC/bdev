#!/bin/bash

function get_line() {
	sed -n "${1}{p;q}" "$2"
}
