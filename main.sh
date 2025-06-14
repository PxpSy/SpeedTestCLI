#!/bin/bash

# Global Variables
CURRENT_DIR=$(pwd)
SCORE=0

# Find command components
declare -a BASE_PATHS=("/" "/etc" "/var" "/home" "/usr" "/tmp" "/opt")
declare -a DEPTH_OPTIONS=("-maxdepth 1" "-maxdepth 2" "-maxdepth 3" "-maxdepth 4" "-mindepth 1" "-mindepth 2")
declare -a TYPE_OPTIONS=("-type f" "-type d" "-type l" "-type s")

# Name patterns by difficulty
declare -a NAMES_EASY=("'*.txt'" "'*.conf'" "'*.sh'" "'*.log'" "'*.cfg'")
declare -a NAMES_MEDIUM=("'*.so'" "'*passwd*'" "'*host*'" "'*ssh*'" "'*config*'")
declare -a NAMES_HARD=("'*bash*'" "'*etc*'" "'*lib*'" "'*bin*'" "'*cron*'")

# Size options
declare -a SIZE_OPTIONS=("-size +1k" "-size -10k" "-size +1M" "-size -100M" "-size +10M")

# Permission options
declare -a PERM_OPTIONS=("-perm 644" "-perm 755" "-perm 777" "-perm /u=r" "-perm /u=w" "-perm /u=x")

# User/Group options
declare -a USER_OPTIONS=("-user root" "-user bin" "-user daemon" "-user mail")
declare -a GROUP_OPTIONS=("-group root" "-group bin" "-group sys" "-group adm")

# Time options
declare -a TIME_OPTIONS=("-mtime -1" "-mtime +1" "-atime -7" "-ctime -30" "-mmin -60" "-amin -120")

# Pipe commands
declare -a PIPE_SIMPLE=("| head -5" "| tail -10" "| wc -l" "| sort")
declare -a PIPE_MEDIUM=("| grep -v '^d'" "| sort -r" "| head -3" "| tail -5")
declare -a PIPE_HARD=("| xargs ls -la" "| awk '{print \$9}'" "| grep -E '\.(txt|log)$'" "| sort | uniq")

# Logical operators
declare -a LOGICAL_OPS=("-o" "-a" "!")

clear_screen() {
    clear
}

execute_command() {
    local command="$1"
    local out
    out=$(eval "$command" 2>/dev/null | head -15)
    clear_screen
    echo "Résultat de la commande mystère :"
    echo "================================"
    if [[ -z "$out" ]]; then
        echo "(aucun résultat)"
    else
        echo "$out"
    fi
    echo "================================"
    printf "%s\n" "$out"
}

show_difficulty_menu() {
    clear_screen
    echo "==============================="
    echo "    ADVANCED FIND COMMAND GAME"
    echo "==============================="
    echo "Score: $SCORE points"
    echo
    echo "Choisissez la difficulté :"
    echo "1) Débutant     (find basique)                    [+1 pt]"
    echo "2) Facile       (avec options simples)            [+2 pts]"
    echo "3) Moyen        (options multiples)               [+3 pts]"
    echo "4) Difficile    (avec pipes et logique)           [+5 pts]"
    echo "5) Expert       (combinaisons complexes)          [+8 pts]"
    echo "6) Maître       (tout inclus + regex)             [+12 pts]"
    echo "7) Afficher les règles"
    echo "8) Quitter"
    echo
}

show_rules() {
    clear_screen
    echo "==============================="
    echo "    RÈGLES DU JEU FIND"
    echo "==============================="
    echo
    echo "NIVEAUX DE DIFFICULTÉ :"
    echo "• Débutant: find basique avec path et -name"
    echo "• Facile: + type, maxdepth"
    echo "• Moyen: + size, permissions, time"
    echo "• Difficile: + pipes, user/group, mindepth"
    echo "• Expert: + opérateurs logiques, regex"
    echo "• Maître: + combinaisons complexes"
    echo
    echo "OPTIONS FIND DISPONIBLES :"
    echo "• Chemins: /, /etc, /var, /home, /usr, /tmp, /opt"
    echo "• Types: -type f|d|l|s (file|directory|link|socket)"
    echo "• Profondeur: -maxdepth N, -mindepth N"
    echo "• Noms: -name, -iname (patterns avec wildcards)"
    echo "• Taille: -size +/-N[k|M|G]"
    echo "• Permissions: -perm [mode]"
    echo "• Utilisateur: -user [name]"
    echo "• Groupe: -group [name]"
    echo "• Temps: -mtime/-atime/-ctime +/-N"
    echo "• Pipes: |head|tail|wc|sort|grep|awk"
    echo "• Logique: -o (OR), -a (AND), ! (NOT)"
    echo
    read -p "Appuyez sur Entrée pour continuer..."
}

compare_results() {
    local orig="$1"
    local user_cmd="$2"
    local user_out
    user_out=$(eval "$user_cmd" 2>/dev/null | head -15)
    
    # Compare sorted results to handle order differences
    if diff <(printf "%s\n" "$orig" | sort) <(printf "%s\n" "$user_out" | sort) &>/dev/null; then
        return 0
    else
        return 1
    fi
}

generate_find_command() {
    local difficulty=$1
    local cmd_parts=()
    
    # Base path
    local base_path="${BASE_PATHS[RANDOM % ${#BASE_PATHS[@]}]}"
    cmd_parts+=("find" "$base_path")
    
    case $difficulty in
        "beginner")
            # Simple find with name only
            cmd_parts+=("${NAMES_EASY[RANDOM % ${#NAMES_EASY[@]}]}")
            cmd_parts=("find" "$base_path" "-name" "${cmd_parts[-1]}")
            ;;
            
        "easy")
            # Add depth and type
            if (( RANDOM % 100 < 70 )); then
                cmd_parts+=("${DEPTH_OPTIONS[RANDOM % 3]}")  # Only maxdepth for easy
            fi
            cmd_parts+=("${TYPE_OPTIONS[RANDOM % 2]}")  # Only f or d
            cmd_parts+=("-name" "${NAMES_EASY[RANDOM % ${#NAMES_EASY[@]}]}")
            ;;
            
        "medium")
            # Add more options
            cmd_parts+=("${DEPTH_OPTIONS[RANDOM % ${#DEPTH_OPTIONS[@]}]}")
            cmd_parts+=("${TYPE_OPTIONS[RANDOM % ${#TYPE_OPTIONS[@]}]}")
            
            if (( RANDOM % 100 < 60 )); then
                cmd_parts+=("${SIZE_OPTIONS[RANDOM % ${#SIZE_OPTIONS[@]}]}")
            fi
            
            if (( RANDOM % 100 < 50 )); then
                cmd_parts+=("-name" "${NAMES_MEDIUM[RANDOM % ${#NAMES_MEDIUM[@]}]}")
            else
                cmd_parts+=("-name" "${NAMES_EASY[RANDOM % ${#NAMES_EASY[@]}]}")
            fi
            ;;
            
        "hard")
            # Add pipes and more complex options
            cmd_parts+=("${DEPTH_OPTIONS[RANDOM % ${#DEPTH_OPTIONS[@]}]}")
            cmd_parts+=("${TYPE_OPTIONS[RANDOM % ${#TYPE_OPTIONS[@]}]}")
            
            if (( RANDOM % 100 < 70 )); then
                cmd_parts+=("${SIZE_OPTIONS[RANDOM % ${#SIZE_OPTIONS[@]}]}")
            fi
            
            if (( RANDOM % 100 < 40 )); then
                cmd_parts+=("${USER_OPTIONS[RANDOM % ${#USER_OPTIONS[@]}]}")
            fi
            
            cmd_parts+=("-name" "${NAMES_HARD[RANDOM % ${#NAMES_HARD[@]}]}")
            
            if (( RANDOM % 100 < 60 )); then
                cmd_parts+=("${PIPE_SIMPLE[RANDOM % ${#PIPE_SIMPLE[@]}]}")
            fi
            ;;
            
        "expert")
            # Complex combinations with logical operators
            cmd_parts+=("${DEPTH_OPTIONS[RANDOM % ${#DEPTH_OPTIONS[@]}]}")
            cmd_parts+=("\\(")
            cmd_parts+=("${TYPE_OPTIONS[RANDOM % ${#TYPE_OPTIONS[@]}]}")
            cmd_parts+=("-name" "${NAMES_HARD[RANDOM % ${#NAMES_HARD[@]}]}")
            cmd_parts+=("${LOGICAL_OPS[0]}")  # -o (OR)
            cmd_parts+=("${SIZE_OPTIONS[RANDOM % ${#SIZE_OPTIONS[@]}]}")
            cmd_parts+=("\\)")
            
            if (( RANDOM % 100 < 50 )); then
                cmd_parts+=("${TIME_OPTIONS[RANDOM % ${#TIME_OPTIONS[@]}]}")
            fi
            
            cmd_parts+=("${PIPE_MEDIUM[RANDOM % ${#PIPE_MEDIUM[@]}]}")
            ;;
            
        "master")
            # Everything included
            cmd_parts+=("${DEPTH_OPTIONS[RANDOM % ${#DEPTH_OPTIONS[@]}]}")
            cmd_parts+=("\\(")
            cmd_parts+=("${TYPE_OPTIONS[RANDOM % ${#TYPE_OPTIONS[@]}]}")
            cmd_parts+=("-name" "${NAMES_HARD[RANDOM % ${#NAMES_HARD[@]}]}")
            cmd_parts+=("${LOGICAL_OPS[0]}")
            cmd_parts+=("${PERM_OPTIONS[RANDOM % ${#PERM_OPTIONS[@]}]}")
            cmd_parts+=("\\)")
            cmd_parts+=("${LOGICAL_OPS[1]}")  # -a (AND)
            cmd_parts+=("${SIZE_OPTIONS[RANDOM % ${#SIZE_OPTIONS[@]}]}")
            
            if (( RANDOM % 100 < 60 )); then
                cmd_parts+=("${USER_OPTIONS[RANDOM % ${#USER_OPTIONS[@]}]}")
            fi
            
            cmd_parts+=("${PIPE_HARD[RANDOM % ${#PIPE_HARD[@]}]}")
            ;;
    esac
    
    echo "${cmd_parts[@]}"
}

play_round() {
    local difficulty=$1
    local points_map=([beginner]=1 [easy]=2 [medium]=3 [hard]=5 [expert]=8 [master]=12)
    local points=${points_map[$difficulty]}
    
    clear_screen
    echo "=== NIVEAU: ${difficulty^^} (+$points points) ==="
    echo
    
    local command original attempts=0 max_attempts=10
    
    # Generate a command that produces results
    while [[ $attempts -lt $max_attempts ]]; do
        command=$(generate_find_command "$difficulty")
        original=$(eval "$command" 2>/dev/null | head -15)
        if [[ -n "$original" ]] && [[ $(echo "$original" | wc -l) -ge 1 ]]; then
            break
        fi
        ((attempts++))
    done
    
    if [[ $attempts -ge $max_attempts ]]; then
        echo "Impossible de générer un exemple valide. Retour au menu..."
        sleep 2
        return
    fi
    
    execute_command "$command"
    echo
    echo "Recreate this result with a 'find' command."
    echo "Hint: difficulty level '$difficulty'"
    echo

    local user_attempts=0
    while true; do
        ((user_attempts++))
        read -e -p "find> " user_cmd
        
        if [[ "$user_cmd" == "hint" ]]; then
            echo "Command structure hint: find [path] [options] [tests] [actions]"
            continue
        fi
        
        if [[ "$user_cmd" == "skip" ]]; then
            echo "Solution était: $command"
            break
        fi

        local user_out
        user_out=$(eval "$user_cmd" 2>/dev/null | head -15)
        echo
        echo "Votre résultat :"
        echo "================================"
        [[ -z "$user_out" ]] && echo "(aucun résultat)" || echo "$user_out"
        echo "================================"
        echo

        if compare_results "$original" "$user_cmd"; then
            echo "🎉 Correct ! (+$points points)"
            ((SCORE+=points))
            
            # Bonus for efficiency
            if [[ $user_attempts -eq 1 ]]; then
                echo "🏆 Premier essai ! Bonus +1 point"
                ((SCORE+=1))
            fi
            
            echo "Score total: $SCORE"
            break
        else
            echo "❌ Pas encore correct. Réessayez..."
            echo "💡 Tapez 'hint' pour une aide ou 'skip' pour passer"
        fi
    done
}

main() {
    while true; do
        show_difficulty_menu
        read -p "Votre choix: " choice
        
        case $choice in
            1) play_round "beginner" ;;
            2) play_round "easy" ;;
            3) play_round "medium" ;;
            4) play_round "hard" ;;
            5) play_round "expert" ;;
            6) play_round "master" ;;
            7) show_rules ;;
            8) 
                echo "🎮 Merci d'avoir joué ! Score final: $SCORE points"
                if [[ $SCORE -gt 50 ]]; then
                    echo "🏆 Excellent score ! Vous maîtrisez find !"
                elif [[ $SCORE -gt 20 ]]; then
                    echo "👍 Bon travail ! Continuez à vous améliorer !"
                else
                    echo "💪 Continuez à pratiquer pour progresser !"
                fi
                exit 0
                ;;
            *)
                echo "❌ Choix invalide"
                sleep 1
                continue
                ;;
        esac
        
        echo
        read -p "Appuyez sur Entrée pour continuer..."
    done
}

main