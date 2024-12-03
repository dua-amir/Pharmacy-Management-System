#!/bin/bash

# Pharmacy Management System
medicine_file="medicines.txt"

# Function to add a medicine
add_medicine() {
    echo -e "\n----- Add New Medicine -----\n"
    echo "Enter Medicine Code:"
    read code
    echo "Enter Medicine Name:"
    read name
    echo "Enter Medicine Quantity:"
    read quantity
    echo "Enter Medicine Price:"
    read price

    echo "$code,$name,$quantity,$price" >> $medicine_file
    echo "Medicine added successfully!"
    echo "-------------------------------------"
}

# Function to update medicine details
update_medicine() {
    echo -e "\n----- Update Medicine -----\n"
    echo "Enter Medicine Name to update:"
    read name
    if grep -q "$name" "$medicine_file"; then
        echo "Enter New Quantity:"
        read quantity
        echo "Enter New Price (whole number only):"
        read price
        sed -i "/$name/ s/,[0-9]*,[0-9.]*/,$quantity,$price/" $medicine_file
        echo "Medicine updated successfully!"
	echo "---------------------------------"
    else
        echo "Medicine not found!"
	echo "---------------------------------"
    fi
}

# Function to delete a medicine
delete_medicine() {
    echo -e "\n----- Delete Medicine -----\n"
    echo "Enter Medicine Name to delete:"
    read name
    if grep -q "$name" "$medicine_file"; then
        sed -i "/$name/d" $medicine_file
        echo "Medicine deleted successfully!"
	echo "-----------------------------------"
    else
        echo "Medicine not found!"
	echo "-----------------------------------"
    fi
}

# Function to search for a medicine
search_medicine() {
    echo -e "\n----- Search Medicine -----\n"
    echo "Enter Medicine Name to search:"
    read name
    if grep -q "$name" "$medicine_file"; then
        echo "Medicine Found:"
        echo "----------------------------------------"
        printf "%-5s | %-20s | %-10s | %-7s\n" "Code" "Name" "Quantity" "Price"
        echo "----------------------------------------"
        grep "$name" "$medicine_file" | while IFS=',' read -r code m_name quantity price; do
            printf "%-5s | %-20s | %-10s | %-7s\n" "$code" "$m_name" "$quantity" "$price"
        done
        echo "----------------------------------------"
    else
        echo "Sorry, medicine not found!"
	echo "----------------------------------------"
    fi
}

# Function to view all medicines
view_medicines() {
    echo -e "\n----- Medicine List -----\n"
    if [ -s $medicine_file ]; then
        echo "----------------------------------------"
        printf "%-5s | %-20s | %-10s | %-7s\n" "Code" "Name" "Quantity" "Price"
        echo "----------------------------------------"
        cat $medicine_file | while IFS=',' read -r code name quantity price; do
            printf "%-5s | %-20s | %-10s | %-7s\n" "$code" "$name" "$quantity" "$price"
        done
        echo "----------------------------------------"
    else
        echo "No medicines available!"
	echo "----------------------------------------"
    fi
}

# Function for customer to purchase medicines
purchase_medicine() {
    echo -e "\n----- Purchase Medicine -----\n"
    echo "Enter Medicine Name to purchase:"
    read medicine_name
    echo "Enter Quantity:"
    read quantity

    medicine=$(grep "$medicine_name" "$medicine_file")

    if [ -z "$medicine" ]; then
        echo "Sorry, medicine not found!"
	echo "-----------------------------------------"
    else
	code=$(echo $medicine | cut -d ',' -f1)
        name=$(echo $medicine | cut -d ',' -f2)
        available_quantity=$(echo $medicine | cut -d ',' -f3)
        price=$(echo $medicine | cut -d ',' -f4)

        if [ "$available_quantity" -eq 0 ]; then
            echo -e "$medicine_name is out of stock.\nStock will update soon."
	    echo "------------------------------------------"
        elif [ "$quantity" -gt "$available_quantity" ]; then
            echo -e "Only $available_quantity available.\nStock will update soon."
	    echo "-------------------------------------------"
        else
            new_quantity=$((available_quantity - quantity))
            total_bill=$(( price * quantity ))
            sed -i "s/^$code,$name,$available_quantity,$price$/$code,$name,$new_quantity,$price/" "$medicine_file"
	    echo "------------------------------------"
            echo -e "\nTotal Bill: $total_bill"
            echo "------------------------------------"
            echo -e "Thank you for purchasing from us!"
        fi
    fi
}

# Admin login function
admin_login() {
    echo "Enter Admin Name:"
    read admin_name
    echo "Enter Admin Password:"
    read -s password
    if [ "$password" == "admin123" ]; then
        echo -e "\n\n\t-----Welcome, $admin_name!-----\n"
    else
        echo "Incorrect password! Access denied."
        echo "----------------------------------"
	exit 1
    fi
}

# Main menu display function
display_menu() {
    clear
    echo -e "\n\n\n\n\n\n"
    echo -e "\t\t\t\t\t\t--------------------------------------"
    echo -e "\t\t\t\t\t\t ____________________________________"
    echo -e "\t\t\t\t\t\t|                                    |"
    echo -e "\t\t\t\t\t\t|      Pharmacy Management System    |"
    echo -e "\t\t\t\t\t\t|____________________________________|"
    echo -e "\t\t\t\t\t\t--------------------------------------\n\n"
    echo -e "\t\t\t\t\t\t             1. Admin Mode\n"
    echo -e "\t\t\t\t\t\t             2. Customer Mode\n"
    echo -e "\t\t\t\t\t\t             3. Exit"
    echo -e "\t\t\t\t\t  ---------------------------------------------------"
}

# Admin menu
admin_menu() {
    echo -e "\n---------- Admin Menu ----------"
    echo "1. Add Medicine"
    echo "2. Update Medicine"
    echo "3. Delete Medicine"
    echo "4. Search Medicine"
    echo "5. View Medicines"
    echo "6. Exit Admin Mode"
    echo "----------------------------------"
}

# Customer menu
customer_menu() {
    echo -e "\n---------- Customer Menu ----------"
    echo "1. View Medicines"
    echo "2. Search Medicine"
    echo "3. Purchase Medicine"
    echo "4. Exit Customer Mode"
    echo "-----------------------------------"
}

# Main program loop
while true; do
    display_menu
    echo -e "\n\n"
    read -p "Please select an option: " role

    if [ "$role" -eq 1 ]; then
        admin_login
        while true; do
            admin_menu
            read -p "Choose an option: " admin_choice

            case $admin_choice in
                1) add_medicine ;;
                2) update_medicine ;;
                3) delete_medicine ;;
                4) search_medicine ;;
                5) view_medicines ;;
                6) break ;;
                *) echo -e "Invalid choice!\n--------------------" ;;
            esac
        done
    elif [ "$role" -eq 2 ]; then
        echo "Enter Customer Name:"
        read customer_name
	echo -e "\n-------------------------------"
        echo -e "\n-----Welcome, $customer_name!-----"
        while true; do
            customer_menu
            read -p "Choose an option: " customer_choice

            case $customer_choice in
                1) view_medicines ;;
                2) search_medicine ;;
                3) purchase_medicine ;;
                4) break ;;
                *) echo -e "Invalid choice!\n--------------------" ;;
            esac
        done
    elif [ "$role" -eq 3 ]; then
        echo -e "\n..........Exiting the system..........\n\t\tGoodbye!!!\n"
        break
    else
        echo "Invalid choice! Please try again."
	echo "---------------------------------"
    fi
done

