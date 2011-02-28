var echidna_util = { };
echidna_util.makeDisplayString = function(original, maxChars) {
    console.debug('original len: ' + original.length + ' max: ' + maxChars);
    if (original.length <= maxChars) return original;
    else return original.substring(0, maxChars - 3) + '...';
};