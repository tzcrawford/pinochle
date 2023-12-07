/*** Defines all of the variables that will be stored among all of the components in the App ***/
import { writable } from 'svelte/store'

export const authToken = writable(null) // Authentication token collected from flask fetch during log-in process

