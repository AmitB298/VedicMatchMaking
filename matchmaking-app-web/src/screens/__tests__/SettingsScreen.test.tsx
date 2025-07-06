// AdminPanelScreen.test.tsx
import { render, screen } from '@testing-library/react';
import AdminPanelScreen from '../AdminPanelScreen';

test('renders admin panel', () => {
    render(<AdminPanelScreen />);
    expect(screen.getByText('Admin Panel')).toBeInTheDocument();
});

