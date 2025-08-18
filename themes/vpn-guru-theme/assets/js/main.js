// Main JavaScript file for VPN Guru theme

document.addEventListener('DOMContentLoaded', function() {
    // Smooth scrolling for anchor links
    const anchorLinks = document.querySelectorAll('a[href^="#"]');
    anchorLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Add active class to current navigation item
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
        if (link.getAttribute('href') === currentPath || 
            (currentPath === '/' && link.getAttribute('href') === '/') ||
            (currentPath.startsWith('/posts') && link.getAttribute('href') === '/posts/')) {
            link.classList.add('active');
        }
    });

    // Mobile menu toggle (if needed in future)
    const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
    const navMenu = document.querySelector('.nav-menu');
    
    if (mobileMenuToggle && navMenu) {
        mobileMenuToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');
            this.classList.toggle('active');
        });
    }

    // Add loading animation to post cards
    const postCards = document.querySelectorAll('.post-card');
    postCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transition = 'all 0.3s ease';
        });
    });

    // Lazy loading for images (if needed)
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.classList.remove('lazy');
                    imageObserver.unobserve(img);
                }
            });
        });

        const lazyImages = document.querySelectorAll('img[data-src]');
        lazyImages.forEach(img => imageObserver.observe(img));
    }

    // Table of Contents active section tracking
    const tocLinks = document.querySelectorAll('.toc-container a[href^="#"]');
    const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
    
    if (tocLinks.length > 0 && headings.length > 0) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    // Remove active class from all TOC links
                    tocLinks.forEach(link => link.classList.remove('active'));
                    
                    // Add active class to current section link
                    const currentId = entry.target.id;
                    const currentLink = document.querySelector(`.toc-container a[href="#${currentId}"]`);
                    if (currentLink) {
                        currentLink.classList.add('active');
                    }
                }
            });
        }, {
            rootMargin: '-20% 0px -70% 0px'
        });

        headings.forEach(heading => {
            if (heading.id) {
                observer.observe(heading);
            }
        });
    }
});
