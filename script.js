document.addEventListener('DOMContentLoaded', () => {
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const navbar = document.querySelector('#navbar');
    const navToggle = document.querySelector('#navToggle');
    const navLinks = document.querySelector('#navLinks');
    const backToTop = document.querySelector('#backToTop');
    const progressBar = document.querySelector('#progressBar');
    const stepsSection = document.querySelector('#steps');

    const updateScrollUi = () => {
        const y = window.scrollY;
        navbar.classList.toggle('scrolled', y > 18);
        backToTop.classList.toggle('visible', y > 650);

        if (stepsSection && progressBar) {
            const start = stepsSection.offsetTop - window.innerHeight * .35;
            const end = stepsSection.offsetTop + stepsSection.offsetHeight - window.innerHeight * .5;
            const progress = Math.max(0, Math.min(1, (y - start) / (end - start)));
            progressBar.style.width = `${progress * 100}%`;
        }
    };
    updateScrollUi();
    window.addEventListener('scroll', updateScrollUi, { passive: true });

    navToggle?.addEventListener('click', () => {
        const open = navLinks.classList.toggle('open');
        navToggle.classList.toggle('open', open);
        navToggle.setAttribute('aria-expanded', String(open));
    });
    navLinks?.querySelectorAll('a').forEach(link => link.addEventListener('click', () => {
        navLinks.classList.remove('open');
        navToggle?.classList.remove('open');
        navToggle?.setAttribute('aria-expanded', 'false');
    }));
    backToTop?.addEventListener('click', () => window.scrollTo({ top: 0, behavior: reducedMotion ? 'auto' : 'smooth' }));

    const stepCards = [...document.querySelectorAll('.step-card')];
    const setStep = (card, open) => {
        card.classList.toggle('is-open', open);
        card.querySelector('.step-toggle')?.setAttribute('aria-expanded', String(open));
    };
    stepCards.forEach((card, index) => {
        const header = card.querySelector('.step-header');
        const toggle = card.querySelector('.step-toggle');
        header?.setAttribute('tabindex', '0');
        header?.setAttribute('role', 'button');
        header?.setAttribute('aria-expanded', 'false');
        const flip = () => setStep(card, !card.classList.contains('is-open'));
        header?.addEventListener('click', event => { if (!event.target.closest('a, button')) flip(); });
        header?.addEventListener('keydown', event => { if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); flip(); } });
        toggle?.addEventListener('click', flip);
        if (index === 0) setStep(card, true);
    });

    const revealElements = document.querySelectorAll('.animate-on-scroll');
    if (reducedMotion || !('IntersectionObserver' in window)) {
        revealElements.forEach(element => element.classList.add('is-visible'));
    } else {
        const revealObserver = new IntersectionObserver(entries => entries.forEach(entry => {
            if (entry.isIntersecting) { entry.target.classList.add('is-visible'); revealObserver.unobserve(entry.target); }
        }), { threshold: .12 });
        revealElements.forEach(element => revealObserver.observe(element));
    }

    const sections = [...document.querySelectorAll('section[id]')];
    const navItems = [...document.querySelectorAll('.nav-link')];
    const activateNav = () => {
        const current = sections.reduce((active, section) => window.scrollY >= section.offsetTop - 130 ? section.id : active, sections[0]?.id);
        navItems.forEach(link => link.classList.toggle('active', link.getAttribute('href') === `#${current}`));
    };
    activateNav(); window.addEventListener('scroll', activateNav, { passive: true });

    document.querySelectorAll('.stat-number[data-count]').forEach(counter => {
        const target = Number(counter.dataset.count);
        const animate = () => {
            if (counter.dataset.done) return;
            counter.dataset.done = 'true';
            if (reducedMotion) { counter.textContent = target; return; }
            const started = performance.now();
            const tick = now => {
                const amount = Math.min(1, (now - started) / 900);
                counter.textContent = Math.round(target * (1 - Math.pow(1 - amount, 3)));
                if (amount < 1) requestAnimationFrame(tick);
            };
            requestAnimationFrame(tick);
        };
        new IntersectionObserver(entries => entries.forEach(entry => entry.isIntersecting && animate()), { threshold: .5 }).observe(counter);
    });

    if (!reducedMotion) {
        const particles = document.querySelector('#particles');
        for (let i = 0; particles && i < 26; i += 1) {
            const dot = document.createElement('span');
            dot.className = 'particle';
            dot.style.left = `${Math.random() * 100}%`;
            dot.style.setProperty('--duration', `${11 + Math.random() * 16}s`);
            dot.style.setProperty('--delay', `${-Math.random() * 22}s`);
            dot.style.opacity = (.12 + Math.random() * .3).toFixed(2);
            particles.appendChild(dot);
        }
    }
});
