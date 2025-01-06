FROM fedora/fedora:41

# Install Terraform
RUN dnf install -y dnf-plugins-core && dnf config-manager --add-repo https://rpm.releases.hashicorp.com/$release/hashicorp.repo

RUN dnf install -y \
    wget \
    curl \
    unzip \
    terraform \
    direnv \
    oci-cli \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Set up direnv hook
RUN echo 'eval "$(direnv hook bash)"' >> ~/.zshrc
RUN echo 'eval "$(direnv hook bash)"' >> ~/.bash_profile