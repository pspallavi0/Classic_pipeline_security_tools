terraform{
    required_providers{
        azurerm={
            source="hashicorp/azurerm"
            version="4.78.0"
        }
    }
    backend"azurerm"{
        resource_group_name="vistara-rg"
        storage_account_name="vistarastg"
        container_name="vistaracontainer"
        key="terraform.tfstate"
    }
}

provider"azurerm"{
    features{}
}