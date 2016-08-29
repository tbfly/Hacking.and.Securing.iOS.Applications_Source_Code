#include <stdio.h>
#include <string.h>
#include <sys/param.h>
#include <ctype.h>
#include <stdlib.h>

int key_distance(char a, char b) {
    const char *qwerty_lc = "`1234567890-="
                            "qwertyuiop[]\\"
                            " asdfghjkl;' "
                            "  zxcvbnm,./ ";
    const char *qwerty_uc = "~!@#$%^&*()_+"
                            "QWERTYUIOP{}|"
                            " ASDFGHJKL:\" "
                            "  ZXCVBNM<>? ";
    int pos_a, pos_b, dist;

    if (strchr(qwerty_lc, a))
        pos_a = strchr(qwerty_lc, a) - qwerty_lc;
    else if (strchr(qwerty_uc, a))
        pos_a = strchr(qwerty_uc, a) - qwerty_uc;
    else
        return -2;

    if (strchr(qwerty_lc, b))
        pos_b = strchr(qwerty_lc, b) - qwerty_lc;
    else if (strchr(qwerty_uc, b))
        pos_b = strchr(qwerty_uc, b) - qwerty_uc;
    else
        return -1;

    dist = abs((pos_a/13) - (pos_b/13))
         + abs(pos_a % 13 - pos_b % 13);
    return dist;
}

int score_passphrase(const char *passphrase) {
    int total_score = 0;
    int unit_score;
    int distances[strlen(passphrase)];
    int i;
  
    /* Password length */
    unit_score = strlen(passphrase) / 4;
    total_score += MIN(3, unit_score);

    /* Uppercase */
    for(unit_score = i = 0; passphrase[i]; ++i) 
        if (isupper(passphrase[i]))
            unit_score++;
    total_score += MIN(3, unit_score);


    /* Lowercase */
    for(unit_score = i = 0; passphrase[i]; ++i) 
        if (islower(passphrase[i])) 
            unit_score++;
    total_score += MIN(3, unit_score);

    /* Digits */
    for(unit_score = i = 0; passphrase[i]; ++i) 
        if (isdigit(passphrase[i])) 
            unit_score++;
    total_score += MIN(3, unit_score);


    /* Special characters */
    for(unit_score = i = 0; passphrase[i]; ++i) 
        if (!isalnum(passphrase[i]))
            unit_score++;
    total_score += MIN(3, unit_score);


    /* Key distance */
    distances[0] = 0;
    for(unit_score = i = 0; passphrase[i]; ++i) {
        if (passphrase[i+1]) {
            int dist = key_distance(passphrase[i], passphrase[i+1]);
            if (dist > 1) {
                int j, exists = 0;
                for(j=0;distances[j];++j) 
                    if (distances[j] == dist)
                        exists = 1;
                if (!exists) {
                    distances[j] = dist;
                    distances[j+1] = 0;
                    unit_score++;
                }
            }
        }
    }
    total_score += MIN(3, unit_score);
   
    return ((total_score / 18.0) * 100);
}


int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Syntax: %s <passphrase>\n", argv[0]);
        return EXIT_FAILURE;
    }
    printf("Passphrase strength: %d%%\n", score_passphrase(argv[1]));
    return EXIT_SUCCESS;
}

