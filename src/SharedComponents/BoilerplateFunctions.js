/*** Here we list some various boilerplate functions we can use anywhere in the project ***/

/*** Form Validation ***/
export function isRequiredFieldValid(value,maxchar=0){
    return value != null && value !== "" && (maxchar==0 || length(value) < maxchar)
}


