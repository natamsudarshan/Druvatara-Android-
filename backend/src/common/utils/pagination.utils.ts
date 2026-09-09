export function paginate<T>(items: T[], page: number = 1, limit: number = 20) {
  const start = (page - 1) * limit;
  const end = start + limit;
  const data = items.slice(start, end);

  return {
    data,
    meta: {
      total: items.length,
      page,
      limit,
      totalPages: Math.ceil(items.length / limit),
      hasNextPage: end < items.length,
      hasPreviousPage: page > 1,
    },
  };
}

export function getPaginationParams(page?: number, limit?: number) {
  return {
    page: Math.max(1, page ?? 1),
    limit: Math.min(100, Math.max(1, limit ?? 20)),
  };
}
